defmodule SocialNetwork.Coherence.RegistrationController do
  @moduledoc """
  Handle account registration actions.

  Actions:

  * new - render the register form
  * create - create a new user account
  * edit - edit the user account
  * update - update the user account
  * delete - delete the user account
  """
  use Coherence.Web, :controller
  require Logger
  alias Coherence.ControllerHelpers, as: Helpers

  alias Bolt.Sips, as: Bolt

  plug Coherence.RequireLogin when action in ~w(show edit update delete)a
  plug Coherence.ValidateOption, :registerable
  plug :scrub_params, "registration" when action in [:create, :update]

  plug :layout_view
  plug :redirect_logged_in when action in [:new, :create]

  @doc false
  def layout_view(conn, _) do
    conn
    |> put_layout({Coherence.LayoutView, "app.html"})
    |> put_view(Coherence.RegistrationView)
  end

  @doc """
  Render the new user form.
  """
  def new(conn, _params) do
    user_schema = Config.user_schema
    cs = Helpers.changeset(:registration, user_schema, user_schema.__struct__)
    conn
    |> render(:new, email: "", changeset: cs)
  end

  @doc """
  Create the new user account.

  Creates the new user account. Create and send a confirmation if
  this option is enabled.
  """
  def create(conn, %{"registration" => registration_params} = params) do
    user_schema = Config.user_schema
    cs = Helpers.changeset(:registration, user_schema, user_schema.__struct__, registration_params)
    case Config.repo.insert(cs) do
      {:ok, user} ->
        conn
        |> send_confirmation(user, user_schema)
        |> redirect_or_login(user, params, Config.allow_unconfirmed_access_for)
      {:error, changeset} ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end

  defp redirect_or_login(conn, _user, params, 0) do
    redirect_to(conn, :registration_create, params)
  end
  defp redirect_or_login(conn, user, params, _) do
    Helpers.login_user(conn, user, params)
  end

  @doc """
  Show the registration page.
  """
  def show(conn, _) do
    user = Coherence.current_user(conn)
    render(conn, "show.html", user: user)
  end

  @doc """
  Edit the registration.
  """
  def edit(conn, _) do
    user = Coherence.current_user(conn)
    changeset = Helpers.changeset(:registration, user.__struct__, user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  @doc """
  Update the registration.
  """
  def update(conn, %{"registration" => user_params} = params) do
    user_schema = Config.user_schema
    user = Coherence.current_user(conn)
    changeset = Helpers.changeset(:registration, user_schema, user, user_params)
    case Config.repo.update(changeset) do
      {:ok, user} ->

        Logger.info  "Here is the user."
        username = user.name
        email = user.email
        Logger.debug "#{inspect(username)} and #{inspect(email)}"
        cypher = """
          MATCH (n:User {email: '#{email}'})
          SET n.name = '#{username}'
          RETURN n
        """
        result = Bolt.query!(Bolt.conn, cypher)
        Logger.info "Here is the result."
        Logger.debug "#{inspect(result)}"

        apply(Config.auth_module, Config.update_login, [conn, user, [id_key: Config.schema_key]])
        |> put_flash(:info, "Account updated successfully.")
        |> redirect_to(:registration_update, params, user)
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  @doc """
  Delete a registration.
  """
  def delete(conn, params) do
    user = Coherence.current_user(conn)
    conn = Coherence.SessionController.delete(conn)
    Config.repo.delete! user

    Logger.info  "Here is the user."
    username = user.name
    email = user.email
    Logger.debug "#{inspect(username)} and #{inspect(email)}"

    cypher = """
      MATCH (n:User {email: '#{email}'})<-[:BELONGS_TO]-(m:Comment)
      DETACH DELETE m
    """
    result = Bolt.query!(Bolt.conn, cypher)
    Logger.info "Here is deleted comments."
    Logger.debug "#{inspect(result)}"

    cypher = """
      MATCH (n:User {email: '#{email}'})<-[:BELONGS_TO]-(m:Post)
      RETURN m
    """
    result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["m"]).properties end)

    Logger.info "Here is all posts."
    Logger.debug "#{inspect(result)}"

    Enum.map(result, fn x  ->
      id = x["id"]
      if x["has_image"] do
        File.rm_rf("./priv/static/uploads/posts/" <> "#{id}")
      end

      cypher = """
        MATCH (n:Post {id: #{id}})<-[:POINTS_TO]-(m:Comment)
        DETACH DELETE m
      """

      result1 = Bolt.query!(Bolt.conn, cypher)
      Logger.info "Here is deleted related comments."
      Logger.debug "#{inspect(result1)}"
    end)

    cypher = """
      MATCH (n:User {email: '#{email}'})<-[:BELONGS_TO]-(m:Post)
      DETACH DELETE m
    """
    result = Bolt.query!(Bolt.conn, cypher)
    Logger.info "Here is deleted posts."
    Logger.debug "#{inspect(result)}"

    cypher = """
      MATCH (n:User {email: '#{email}'})
      DETACH DELETE n
    """
    result = Bolt.query!(Bolt.conn, cypher)
    Logger.info "Here is deleted user."
    Logger.debug "#{inspect(result)}"

    SocialNetwork.Endpoint.broadcast("user:" <> email, "delete_user", %{email: email})

    redirect_to(conn, :registration_delete, params)
  end
end
