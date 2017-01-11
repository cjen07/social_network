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
        OPTIONAL MATCH (b)-[:REFERS_TO]->(d:User)
        RETURN b AS comment, c AS user, d AS refer
        ORDER BY b.time
      """

      result1 = Bolt.query!(Bolt.conn, cypher)

      Logger.info "here is all comments result1"
      Logger.debug "#{inspect(result1)}"

      thumbs = result
      comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
      users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
      refers = result1 |> Enum.map(fn x -> 
          refer = x["refer"]
          case refer do
            nil -> %{}
            _ -> refer.properties            
          end
        end)

      comments = 
        Enum.zip(comments, users) 
        |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)
        |> Enum.zip(refers)
        |> Enum.map(fn {c, r} -> Map.put(c, "refer", r) end)

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
        OPTIONAL MATCH (b)-[:REFERS_TO]->(d:User)
        RETURN b AS comment, c AS user, d AS refer
        ORDER BY b.time
      """

      result1 = Bolt.query!(Bolt.conn, cypher)

      Logger.info "here is all comments result1"
      Logger.debug "#{inspect(result1)}"

      thumbs = result
      comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
      users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
      refers = result1 |> Enum.map(fn x -> 
          refer = x["refer"]
          case refer do
            nil -> %{}
            _ -> refer.properties            
          end
        end)

      comments = 
        Enum.zip(comments, users) 
        |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)
        |> Enum.zip(refers)
        |> Enum.map(fn {c, r} -> Map.put(c, "refer", r) end)

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
        OPTIONAL MATCH (b)-[:REFERS_TO]->(d:User)
        RETURN b AS comment, c AS user, d AS refer
        ORDER BY b.time
      """

      result1 = Bolt.query!(Bolt.conn, cypher)

      Logger.info "here is all comments result1"
      Logger.debug "#{inspect(result1)}"

      thumbs = result
      comments = result1 |> Enum.map(fn x -> (x["comment"]).properties end)
      users = result1 |> Enum.map(fn x -> (x["user"]).properties end)
      refers = result1 |> Enum.map(fn x -> 
          refer = x["refer"]
          case refer do
            nil -> %{}
            _ -> refer.properties            
          end
        end)

      comments = 
        Enum.zip(comments, users) 
        |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)
        |> Enum.zip(refers)
        |> Enum.map(fn {c, r} -> Map.put(c, "refer", r) end)

      x 
      |> Map.put("thumbs", :erlang.term_to_binary(thumbs))
      |> Map.put("comments", :erlang.term_to_binary(comments))
    end)

    Logger.info "here is result3"
    Logger.debug "#{inspect(result3)}"

    posts = result3
    render(conn, "index.html", posts: posts, user: %{"name" => username, "email" => email}, type: "2")
  end

  def create_post(conn, %{"token_time" => token_time}) do

    user = Coherence.current_user(conn)
    email = user.email

    post = conn.params["post"]
    text = post["text"]
    photo = post["photo"]
    time = DateTime.utc_now() |> DateTime.to_unix()

    Logger.info "here is new post"
    Logger.debug "#{inspect(post)}"

    cypher = """
      MERGE (id:Id {name:'post'})
      ON CREATE SET id.count = 0
      ON MATCH SET id.count = id.count + 1
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

    SocialNetwork.Endpoint.broadcast("user:" <> email, "new_post", %{email: email, token_time: String.to_integer(token_time)})

    conn
    |> put_flash(:info, "Post created successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  def delete_post(conn, %{"post" => post, "token_time" => token_time}) do

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

    if Map.get(result, :stats) == nil do
      # unless in almost all cases now
      conn
      |> put_flash(:info, "Post is already deleted.")
      |> redirect(to: post_path(conn, :index))

    else

      if post["has_image"] == "true" do
        File.rm_rf("./priv/static/uploads/posts/" <> "#{id}")
      end

      email = Coherence.current_user(conn).email
      SocialNetwork.Endpoint.broadcast("user:" <> email, "delete_post", %{post_id: id, email: email, token_time: String.to_integer(token_time)})

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: post_path(conn, :index))

    end

  end

  defp get_thumbs(conn, id) do

    cypher = """
      MATCH (a:Post {id: #{id}})<-[b:THUMBED]-(c:User)
      RETURN c
      ORDER BY b.time
    """
    result = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["c"]).properties end)

    Logger.info "here is thumbed result"
    Logger.debug "#{inspect(result)}"

    result1 = Enum.map(result, fn x ->
      Map.put(x, "self", x["email"] == Coherence.current_user(conn).email)
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

    {thumbs, has_image}

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

    result0 = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is thumb change result0"
    Logger.debug "#{inspect(result0)}"

    cypher = """
      MATCH (a:Post {id: #{id}})-[:BELONGS_TO]->(b:User)
      RETURN b
    """

    result = Bolt.query!(Bolt.conn, cypher)

    if result == [] do

      render(conn, "thumb.json", error: "the post is deleted")
      
    else

      result = result |> Enum.map(fn x -> (x["b"]).properties end) |> Enum.at(0)

      that_email = result["email"]

      if is_list(result0) do
        SocialNetwork.Endpoint.broadcast("user:" <> that_email, "new_thumb", %{post_id: id, email: email, type: "thumb"})
      else
        SocialNetwork.Endpoint.broadcast("user:" <> that_email, "delete_thumb", %{post_id: id, email: email, type: "thumb"})
      end

      {thumbs, has_image} = get_thumbs(conn, id)

      render(conn, "thumb.json", thumb: (span_id == "1"), thumbs: thumbs, has_image: has_image)

    end    

  end

  def get_home_message(conn, %{"post_id" => post_id}) do

    id = String.to_integer(post_id)

    comments = get_comments(conn, id)
    {thumbs, has_image} = get_thumbs(conn, id)

    render(conn, "home_message.json", comments: comments, thumbs: thumbs, has_image: has_image)
    
  end

  defp get_comments(conn, id) do

    cypher = """
      MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment)-[:BELONGS_TO]->(c:User)
      OPTIONAL MATCH (b)-[:REFERS_TO]->(d:User)
      RETURN b AS comment, c AS user, d AS refer
      ORDER BY b.time
    """

    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is all comments result"
    Logger.debug "#{inspect(result)}"

    comments = result |> Enum.map(fn x -> (x["comment"]).properties end)
    users = result |> Enum.map(fn x -> (x["user"]).properties end)
    refers = result |> Enum.map(fn x -> 
        refer = x["refer"]
        case refer do
          nil -> %{}
          _ -> refer.properties            
        end
      end)

    Enum.zip(comments, users) 
    |> Enum.map(fn {c, u} -> Map.put(c, "user", u) end)
    |> Enum.zip(refers)
    |> Enum.map(fn {c, r} -> Map.put(c, "refer", r) end)
    |> Enum.map(fn c -> Map.put(c, "self", c["user"]["email"] == Coherence.current_user(conn).email) end)
    
  end

  def create_comment(conn, %{"post_id" => post_id, "comment" => comment, "email" => email0}) do
    
    Logger.info "here is post_id"
    Logger.debug "#{inspect(post_id)}"

    Logger.info "here is comment"
    Logger.debug "#{inspect(comment)}"

    Logger.info "here is email0"
    Logger.debug "#{inspect(email0)}"

    user = Coherence.current_user(conn)
    email = user.email

    id = String.to_integer(post_id)
    time = DateTime.utc_now() |> DateTime.to_unix()

    cypher = 
    case email0 do
      "" -> 
        """
          MATCH (a:Post {id: #{id}}), (c:User {email: '#{email}'})
          CREATE (a)<-[:POINTS_TO]-(b:Comment {text: "#{comment}", time: #{time}})-[:BELONGS_TO]->(c)
          RETURN b
        """
      _ ->
        """
          MATCH (a:Post {id: #{id}}), (c:User {email: '#{email}'}), (d:User {email: '#{email0}'})
          CREATE (a)<-[:POINTS_TO]-(b:Comment {text: "#{comment}", time: #{time}})-[:BELONGS_TO]->(c)
          CREATE (b)-[:REFERS_TO]->(d)
          RETURN b
        """
    end

    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is created comment result"
    Logger.debug "#{inspect(result)}"

    if result == [] do

      render(conn, "comment.json", error: "the post is deleted")
      
    else

      if email0 == "" do

        cypher = """
          MATCH (a:Post {id: #{id}})-[:BELONGS_TO]->(b: User)
          RETURN b
        """
        result0 = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["b"]).properties end) |> Enum.at(0)

        Logger.info "here is post owner result0"
        Logger.debug "#{inspect(result0)}"

        that_email = result0["email"]

        if that_email != email, do: SocialNetwork.Endpoint.broadcast("user:" <> that_email, "new_comment", %{post_id: id, email: email, time: time, type: "comment"})

      end

      comments = get_comments(conn, id)

      render(conn, "comment.json", comments: comments)

    end
  end

  def delete_comment(conn, %{"post_id" => post_id, "time" => time}) do

    Logger.info "here is post_id"
    Logger.debug "#{inspect(post_id)}"

    Logger.info "here is time"
    Logger.debug "#{inspect(time)}"

    user = Coherence.current_user(conn)
    email = user.email

    id = String.to_integer(post_id)
    time = String.to_integer(time)

    cypher = """
      MATCH (a:Post {id: #{id}})<-[:POINTS_TO]-(b:Comment {time: #{time}})-[:BELONGS_TO]->(c:User {email: '#{email}'})
      DETACH DELETE b
    """
    result = Bolt.query!(Bolt.conn, cypher)

    Logger.info "here is deleted comment result"
    Logger.debug "#{inspect(result)}"

    cypher = """
      MATCH (a:Post {id: #{id}})
      RETURN a
    """

    result = Bolt.query!(Bolt.conn, cypher)

    if result == [] do

      render(conn, "comment.json", error: "the post is deleted")
      
    else

      cypher = """
        MATCH (a:Post {id: #{id}})-[:BELONGS_TO]->(b: User)
        RETURN b
      """
      result0 = Bolt.query!(Bolt.conn, cypher) |> Enum.map(fn x -> (x["b"]).properties end) |> Enum.at(0)

      Logger.info "here is post owner result0"
      Logger.debug "#{inspect(result0)}"

      that_email = result0["email"]

      if that_email != email, do: SocialNetwork.Endpoint.broadcast("user:" <> that_email, "delete_comment", %{post_id: id, email: email, time: time, type: "comment"})

      comments = get_comments(conn, id)

      render(conn, "comment.json", comments: comments)

    end
    
  end

end
