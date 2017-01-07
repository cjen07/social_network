defmodule SocialNetwork.UserView do
  use SocialNetwork.Web, :view

  def render("friends.json", %{friends: friends}) do
    %{friends: friends}
  end

end
