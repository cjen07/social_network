defmodule SocialNetwork.PageController do
  use SocialNetwork.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def lobby(conn, _params) do
    render conn, "lobby.html"
  end
end
