defmodule SocialNetwork.PageControllerTest do
  use SocialNetwork.IntegrationCase, async: true

  test "GET /", %{session: session} do

    welcome = 
      session
      |> visit("/")
      |> find(".jumbotron")
      |> text
    assert welcome =~ "Welcome to Social Network!"
  end
end
