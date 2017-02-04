defmodule SocialNetwork.UserChannel do
  use Phoenix.Channel
  alias SocialNetwork.Presence

  require Logger

  def join("user:" <> email0, _params, socket) do
    {email, _} = socket.assigns.user
    if email0 == email do
      send self(), :after_join
    end
    {:ok, "Joined successfully", socket}
  end

  def handle_info(:after_join, socket) do
    {email, _} = socket.assigns.user
    Presence.track(socket, email, %{
      online_at: :os.system_time(:milli_seconds)
    })
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  intercept ["new_post", "delete_post"]

  def handle_out("new_post", payload, socket) do
    {email, time} = socket.assigns.user
    if payload.email != email or time != payload.token_time do
      Process.sleep(1000) # delay other endpoints
      push socket, "new_post", payload
    end
    {:noreply, socket}
  end

  def handle_out("delete_post", payload, socket) do
    {email, time} = socket.assigns.user
    if payload.email != email or time != payload.token_time do
      Process.sleep(1000) # delay other endpoints
      push socket, "delete_post", payload
    end
    {:noreply, socket}
  end

end