defmodule SocialNetwork.Router do
  use SocialNetwork.Web, :router
  use Coherence.Router

  require Logger

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SocialNetwork do
    pipe_through :browser
    coherence_routes
  end
  
  scope "/", SocialNetwork do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", SocialNetwork do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/", SocialNetwork do
    pipe_through :protected

    get "/users", UserController, :index
    get "/users/search", UserController, :search_form
    post "/users/search", UserController, :search_submit
    get "/users/fof", UserController, :friends_of_friends
    post "/users", UserController, :follow
    delete "/users", UserController, :unfollow 

    get "/home", PostController, :index
    get "/hub", PostController, :friend
    get "/news", PostController, :news
    post "/home", PostController, :create_post
    delete "/home", PostController, :delete_post

  end

  # Other scopes may use custom stacks.
  scope "/api", SocialNetwork do
    pipe_through :api
    pipe_through :protected
    get "/thumb", PostController, :thumb
    get "/message/home", PostController, :get_home_message
    get "/comment/create", PostController, :create_comment
    get "/comment/delete", PostController, :delete_comment
    get "/friends", UserController, :get_friends
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      # this is a very tricky method
      time = :rand.uniform(10000000000000000000)
      token = Phoenix.Token.sign(conn, "user socket", {current_user.email, time})
      conn
      |> assign(:user_token, token)
      |> assign(:token_time, time)
    else
      conn
    end
  end

end
