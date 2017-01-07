defmodule SocialNetwork.UserController do
  use SocialNetwork.Web, :controller

  alias Bolt.Sips, as: Bolt

  require Logger

  def index(conn, _params) do

    user = Coherence.current_user(conn)

    Logger.info  "Here is the user."
    username = user.name
    email = user.email
    Logger.debug "#{inspect(username)} and #{inspect(email)}"
    cypher = """
      MATCH (a:User {email: '#{email}'})-[:FOLLOWS]->(b)
      RETURN b
    """
    result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["b"]).properties end)
    Logger.info "Here is the result."
    Logger.debug "#{inspect(result)}"

    users = result
    now = :erlang.term_to_binary([%{"name" => username, "email" => email}])
    render(conn, "index.html", users: users,
      now: now, fof: false, search: false)

  end

  def get_friends(conn, _params) do

    user = Coherence.current_user(conn)

    Logger.info  "Here is the user."
    username = user.name
    email = user.email
    Logger.debug "#{inspect(username)} and #{inspect(email)}"
    cypher = """
      MATCH (a:User {email: '#{email}'})-[:FOLLOWS]->(b)
      RETURN b
    """
    result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["b"]).properties end)
    Logger.info "Here is the result."
    Logger.debug "#{inspect(result)}"

    friends = result
    render(conn, "friends.json", friends: friends)
  end

  def search_form(conn, %{"fof" => fof, "now" => now}) do
    Logger.info "Here is the fof."
    Logger.debug "#{inspect(fof)}"
    render(conn, "search.html", fof: fof == "true", now: now)
  end

  def search_submit(conn, %{"search" => search}) do
    search_submit_helper(conn, search)
  end

  def search_submit(conn, _params) do
    search = conn.params["search"]
    search_submit_helper(conn, search)
  end

  def search_submit_helper(conn, search) do

    user0 = Coherence.current_user(conn)

    Logger.info  "Here is the user0."
    username0 = user0.name
    email0 = user0.email
    Logger.debug "#{inspect(username0)} and #{inspect(email0)}"

    Logger.info  "Here is the search."
    username1 = search["name"]
    email1 = search["email"]
    Logger.debug "#{inspect(username1)} and #{inspect(email1)}"

    cypher = """
      MATCH (a:User)
      WHERE a.name CONTAINS '#{username1}' AND a.email CONTAINS '#{email1}'
      RETURN a
    """
    result0 = 
      Bolt.query!(Bolt.conn, cypher) 
      |> Enum.map(fn x -> (x["a"]).properties end)
      |> Enum.filter(fn x -> x["email"] != Coherence.current_user(conn).email end)
    Logger.info "Here is the result0."
    Logger.debug "#{inspect(result0)}"

    result1 = Enum.map(result0, fn x -> 
      email = x["email"]
      cypher = """
        MATCH (a:User {email: '#{email0}'})-[r:FOLLOWS]->(b:User {email: '#{email}'})
        RETURN r
      """
      Bolt.query!(Bolt.conn, cypher) != []
    end)

    Logger.info "Here is the result1."
    Logger.debug "#{inspect(result1)}"

    result2 = Enum.zip(result0, result1) |> Enum.map(fn {x, e} -> Map.put(x, "flag", e) end)

    Logger.info "Here is the result2."
    Logger.debug "#{inspect(result2)}"

    users = result2
    now = :erlang.term_to_binary([Map.put(search, "search", true)])
    render(conn, "index.html", users: users, search: true,
     fof: false, now: now)

  end

  def friends_of_friends(conn, %{"user" => user, "now" => now}) do

    user0 = Coherence.current_user(conn)

    Logger.info  "Here is the user0."
    username0 = user0.name
    email0 = user0.email
    Logger.debug "#{inspect(username0)} and #{inspect(email0)}"
    
    Logger.info  "Here is the user1."
    username1 = user["name"]
    email1 = user["email"]
    Logger.debug "#{inspect(username1)} and #{inspect(email1)}"

    cypher = 
      cond do
        user["type"] == "0" ->
          """
            MATCH (a:User {email: '#{email1}'})-[:FOLLOWS]->(b)
            RETURN b
          """
        :true ->
          """
            MATCH (a:User {email: '#{email1}'})<-[:FOLLOWS]-(b)
            RETURN b
          """
      end

    result0 = 
      Bolt.query!(Bolt.conn, cypher) 
      |> Enum.map(fn x -> (x["b"]).properties end) 

    Logger.info "Here is the result0."
    Logger.debug "#{inspect(result0)}"

    result1 = Enum.map(result0, fn x -> 
      email = x["email"]
      cypher = """
        MATCH (a:User {email: '#{email0}'})-[r:FOLLOWS]->(b:User {email: '#{email}'})
        RETURN r
      """
      Bolt.query!(Bolt.conn, cypher) != []
    end)

    Logger.info "Here is the result1."
    Logger.debug "#{inspect(result1)}"

    result2 = Enum.zip(result0, result1) |> Enum.map(fn {x, e} -> Map.put(x, "flag", e) end)

    Logger.info "Here is the result2."
    Logger.debug "#{inspect(result2)}"

    users = result2
    now = :erlang.term_to_binary([user | :erlang.binary_to_term(now)])
    render(conn, "index.html", users: users, now: now, fof: true, search: false)

  end

  def follow(conn, %{"user" => user, "now" => now}) do

    user0 = Coherence.current_user(conn)

    Logger.info  "Here is the user0."
    username0 = user0.name
    email0 = user0.email
    Logger.debug "#{inspect(username0)} and #{inspect(email0)}"
    
    Logger.info  "Here is the user1."
    username1 = user["name"]
    email1 = user["email"]
    Logger.debug "#{inspect(username1)} and #{inspect(email1)}"

    cypher = """
      MATCH (a:User {email: '#{email0}'}),(b:User {email: '#{email1}'})
      CREATE (a)-[:FOLLOWS]->(b)
    """
    result = Bolt.query!(Bolt.conn, cypher)
    Logger.info "Here is the result."
    Logger.debug "#{inspect(result)}"

    [h|t] = :erlang.binary_to_term(now)

    if h["search"] do
      conn
      |> put_flash(:info, "Friend followed successfully.")
      |> search_submit_helper(h)
    else
      t = :erlang.term_to_binary(t)
      conn
      |> put_flash(:info, "Friend followed successfully.")
      |> redirect(to: user_path(conn, :friends_of_friends, %{:user => h, :now => t}))
    end

  end

  def unfollow(conn, %{"user" => user, "now" => now}) do

    user0 = Coherence.current_user(conn)

    Logger.info  "Here is the user0."
    username0 = user0.name
    email0 = user0.email
    Logger.debug "#{inspect(username0)} and #{inspect(email0)}"
    
    Logger.info  "Here is the user1."
    username1 = user["name"]
    email1 = user["email"]
    Logger.debug "#{inspect(username1)} and #{inspect(email1)}"

    cypher = """
      MATCH (a:User {email: '#{email0}'})-[r:FOLLOWS]->(b:User {email: '#{email1}'})
      DELETE r
    """
    result = Bolt.query!(Bolt.conn, cypher)
    Logger.info "Here is the result."
    Logger.debug "#{inspect(result)}"

    now = :erlang.binary_to_term(now)

    if now == [] do
      conn
      |> put_flash(:info, "Friend unfollowed successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      [h|t] = now
      if h["search"] do
        conn
        |> put_flash(:info, "Friend unfollowed successfully.")
        |> search_submit_helper(h)
      else
        t = :erlang.term_to_binary(t)
        conn
        |> put_flash(:info, "Friend unfollowed successfully.")
        |> redirect(to: user_path(conn, :friends_of_friends, %{:user => h, :now => t}))
      end
    end

  end

end