defmodule SocialNetwork.PostView do
  use SocialNetwork.Web, :view

  def render("thumb.json", %{thumb: thumb, thumbs: thumbs, has_image: has_image}) do
    %{thumb: thumb, thumbs: thumbs, has_image: has_image}
  end

  def render("comment.json", %{comments: comments}) do
    comments = 
      comments
      |> Enum.map(fn c -> Map.put(c, "time", parse_time(c["time"])) end)
      |> Enum.map(fn c -> Map.put(c, "url", Exgravatar.gravatar_url(c["user"]["email"], secure: false, s: 50)) end)
    %{comments: comments}
  end

  def parse_time(time) do
    time 
    |> DateTime.from_unix!()
    |> DateTime.to_string()
    |> Timex.Parse.DateTime.Parser.parse("{RFC3339z}")
    |> elem(1)
    |> Timex.from_now()
    |> String.replace("-", "")
  end

end
