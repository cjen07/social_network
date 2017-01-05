defmodule SocialNetwork.PageController do
  use SocialNetwork.Web, :controller

  def index(conn, _params) do
      render conn, "index.html"
  end
end
