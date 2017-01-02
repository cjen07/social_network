defmodule SocialNetwork.PostController do
  use SocialNetwork.Web, :controller

  alias Bolt.Sips, as: Bolt

  require Logger

  def index(conn, _params) do
    user = Coherence.current_user(conn)
    username = user.name
    email = user.email

    cypher = """
      MATCH (a:Post)-[:BELONGS_TO]->(b:User {email: '#{email}'})
      RETURN a
      ORDER BY a.time DESC
    """
    result0 = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["a"]).properties end)

    Logger.info "here is current result0"
    Logger.debug "#{inspect(result0)}"

    result1 = Enum.map(result0, fn x ->
      id = x["id"]
      cypher = """
        MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User)
        RETURN c
        ORDER BY b.time
      """
      result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["c"]).properties end)

      Logger.info "here is thumbed result"
      Logger.debug "#{inspect(result)}"

      cypher = """
        MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment)-[:BELONGS_TO]->(c:User)
        RETURN b As comment, c As user
        ORDER BY b.time
      """

      result1 = Bolt.query!(Bolt.conn, cypher)

      Logger.info "here is all comments result1"
      Logger.debug "#{inspect(result1)}"

      thumbs = result
      comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
      users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
      comments = Enum.zip(comments, users) |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)

      x 
      |> Map.put("thumbs", :erlang.term_to_binary(thumbs))
      |> Map.put("comments", :erlang.term_to_binary(comments))
    end)

    Logger.info "here is result1"
    Logger.debug "#{inspect(result1)}"

    posts = result1
    render(conn, "index.html", posts: posts, user: %{"name" => username, "email" => email}, type: "0")
  end

  def friend(conn, %{"user" => user}) do
    email = user["email"]
    
    cypher = """
      MATCH (a:Post)-[:BELONGS_TO]->(b:User {email: '#{email}'})
      RETURN a
      ORDER BY a.time DESC
    """
    result0 = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["a"]).properties end)

    Logger.info "here is result0"
    Logger.debug "#{inspect(result0)}"

    email = Coherence.current_user(conn).email

    result1 = Enum.map(result0, fn x -> 
      id = x["id"]
      cypher = """
        MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User {email: '#{email}'})
        RETURN b
      """
      Bolt.query!(Bolt.conn, cypher) != []
    end)

    Logger.info "Here is the result1."
    Logger.debug "#{inspect(result1)}"

    result2 = Enum.zip(result0, result1) |> Enum.map(fn {x, e} -> Map.put(x, "thumbed", e) end)

    Logger.info "Here is the result2."
    Logger.debug "#{inspect(result2)}"

    result3 = Enum.map(result2, fn x ->
      id = x["id"]
      cypher = """
        MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User)
        RETURN c
        ORDER BY b.time
      """
      result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["c"]).properties end)

      Logger.info "here is thumbed result"
      Logger.debug "#{inspect(result)}"

      cypher = """
        MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment)-[:BELONGS_TO]->(c:User)
        RETURN b As comment, c As user
        ORDER BY b.time
      """

      result1 = Bolt.query!(Bolt.conn, cypher)

      Logger.info "here is all comments result1"
      Logger.debug "#{inspect(result1)}"

      thumbs = result
      comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
      users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
      comments = Enum.zip(comments, users) |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)

      x 
      |> Map.put("thumbs", :erlang.term_to_binary(thumbs))
      |> Map.put("comments", :erlang.term_to_binary(comments))
    end)

    Logger.info "here is result3"
    Logger.debug "#{inspect(result3)}"

    posts = result3
    render(conn, "index.html", posts: posts, user: user, type: "1")
  end

  def news(conn, _params) do

    user = Coherence.current_user(conn)
    username = user.name
    email = user.email

    cypher = """
      MATCH (a:Post)-[:BELONGS_TO]->(b:User)<-[:FOLLOWS]-(c:User {email: '#{email}'})
      RETURN a AS post, b AS user
      ORDER BY a.time DESC
    """
    result0 = Bolt.query!(Bolt.conn, cypher)

    posts = result0 |> Enum.map(fn x -> (x["post"]).properties end)
    users = result0 |> Enum.map(fn x -> (x["user"]).properties end)
    result0 = Enum.zip(posts, users) |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)

    Logger.info "here is result0"
    Logger.debug "#{inspect(result0)}"

    result1 = Enum.map(result0, fn x -> 
      id = x["id"]
      cypher = """
        MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User {email: '#{email}'})
        RETURN b
      """
      Bolt.query!(Bolt.conn, cypher) != []
    end)

    Logger.info "Here is the result1."
    Logger.debug "#{inspect(result1)}"

    result2 = Enum.zip(result0, result1) |> Enum.map(fn {x, e} -> Map.put(x, "thumbed", e) end)

    Logger.info "Here is the result2."
    Logger.debug "#{inspect(result2)}"

    result3 = Enum.map(result2, fn x ->
      id = x["id"]
      cypher = """
        MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User)
        RETURN c
        ORDER BY b.time
      """
      result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["c"]).properties end)

      Logger.info "here is thumbed result"
      Logger.debug "#{inspect(result)}"

      cypher = """
        MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment)-[:BELONGS_TO]->(c:User)
        RETURN b As comment, c As user
        ORDER BY b.time
      """

      result1 = Bolt.query!(Bolt.conn, cypher)

      Logger.info "here is all comments result1"
      Logger.debug "#{inspect(result1)}"

      thumbs = result
      comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
      users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
      comments = Enum.zip(comments, users) |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)

      x 
      |> Map.put("thumbs", :erlang.term_to_binary(thumbs))
      |> Map.put("comments", :erlang.term_to_binary(comments))
    end)

    Logger.info "here is result3"
    Logger.debug "#{inspect(result3)}"

    posts = result3
    render(conn, "index.html", posts: posts, user: %{"name" => username, "email" => email}, type: "2")
  end

  def create_post(conn, _params) do

    user = Coherence.current_user(conn)
    email = user.email

    post = conn.params["post"]
    text = post["text"]
    photo = post["photo"]
    time = DateTime.utc_now() |> DateTime.to_unix()

    Logger.info "here is new post"
    Logger.debug "#{inspect(post)}"

    cypher = """
      MATCH (id:Id {name:'post'})
      SET id.count = id.count + 1
      RETURN id.count as id
    """
    id = Bolt.query!(Bolt.conn, cypher) |> Enum.at(0) |> Map.get("id")

    Logger.info "here is id"
    Logger.debug "#{inspect(id)}"

    cypher = 
    case photo do
      nil ->
        """
          MATCH (a:User {email: '#{email}'})
          CREATE (p:Post {id: #{id}, has_image: false, file: '', text: "#{text}", time: #{time}})-[:BELONGS_TO]->(a)
        """
      _ ->
        {:ok, file} = Image.store({photo, id})
        """
          MATCH (a:User {email: '#{email}'})
          CREATE (p:Post {id: #{id}, has_image: true, file: '#{file}', text: "#{text}", time: #{time}})-[:BELONGS_TO]->(a)
        """   
    end

    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is created result"
    Logger.debug "#{inspect(result)}"

    conn
    |> put_flash(:info, "Post created successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  def delete_post(conn, post) do

    Logger.info "here is the post"
    Logger.debug "#{inspect(post)}"

    id = post["id"]

    cypher = """
      MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment)
      DETACH DELETE b
    """
    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is comment delete result"
    Logger.debug "#{inspect(result)}"

    cypher = """
      MATCH (a:Post {id: #{id}})
      DETACH DELETE a
    """
    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is post delete result"
    Logger.debug "#{inspect(result)}"

    if post["has_image"] == "true" do
      File.rm_rf("./priv/static/uploads/posts/" <> "#{id}")
    end

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  def thumb(conn, %{"post_id" => post_id, "span_id" => span_id}) do

    user = Coherence.current_user(conn)
    email = user.email

    id = String.to_integer(post_id)
    time = DateTime.utc_now() |> DateTime.to_unix()

    cypher = 
    case span_id do
      "1" ->
        """
          MATCH (a:Post {id: #{id}}), (c:User {email: '#{email}'})
          MERGE (a)<-[b:THUMBED]-(c)
          ON CREATE SET b.time = #{time}
          RETURN b
        """
      _ ->
        """
          MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User {email: '#{email}'})
          DELETE b
        """ 
    end

    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is result"
    Logger.debug "#{inspect(result)}"

    cypher = """
      MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User)
      RETURN c
      ORDER BY b.time
    """
    result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["c"]).properties end)

    Logger.info "here is thumbed result"
    Logger.debug "#{inspect(result)}"

    result1 = Enum.map(result, fn x ->
      Map.put(x, "self", x["email"] == email)
    end)

    thumbs = result1

    cypher = """
      MATCH (a:Post {id: #{id}})
      RETURN a.has_image AS b
    """

    result2 = Bolt.query!(Bolt.conn, cypher) |> Enum.at(0)

    Logger.info "here is result2"
    Logger.debug "#{inspect(result2)}"

    has_image = result2["b"]

    render(conn, "thumb.json", thumb: (span_id == "1"), thumbs: thumbs, has_image: has_image)    

  end

  def comment(conn, %{"post_id" => post_id, "comment" => comment}) do
    
    Logger.info "here is post_id"
    Logger.debug "#{inspect(post_id)}"

    Logger.info "here is comment"
    Logger.debug "#{inspect(comment)}"

    user = Coherence.current_user(conn)
    email = user.email

    id = String.to_integer(post_id)
    time = DateTime.utc_now() |> DateTime.to_unix()

    cypher = """
      MATCH (a:Post {id: #{id}}), (c:User {email: '#{email}'})
      CREATE (a)<-[:POINTS_TO]-(b:Comment {text: "#{comment}", time: #{time}})-[:BELONGS_TO]->(c)
      RETURN b
    """
    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is created comment result"
    Logger.debug "#{inspect(result)}"

    cypher = """
      MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment)-[:BELONGS_TO]->(c:User)
      RETURN b As comment, c As user
      ORDER BY b.time
    """

    result1 = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is all comments result1"
    Logger.debug "#{inspect(result1)}"

    comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
    users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
    comments = 
      Enum.zip(comments, users)
      |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)

    render(conn, "comment.json", comments: comments)
  end

end
