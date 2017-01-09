defmodule SocialNetwork.UserChannel do
  use Phoenix.Channel

  require Logger

  def join("user:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("user:" <> _email, _params, socket) do
    {:ok, "Joined successfully", socket}
  end

  intercept ["new_post", "delete_post"]

  def handle_out("new_post", payload, socket) do

    {email, time} = Map.get(Map.get(socket, :assigns), :user)

    if payload.email != email or time != payload.token_time do
      Process.sleep(1000) # delay other endpoints
      push socket, "new_post", payload
    end
    {:noreply, socket}
  end

  def handle_out("delete_post", payload, socket) do

    {email, time} = Map.get(Map.get(socket, :assigns), :user)

    if payload.email != email or time != payload.token_time do
      Process.sleep(1000) # delay other endpoints
      push socket, "delete_post", payload
    end
    {:noreply, socket}
  end

end