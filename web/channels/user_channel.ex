defmodule SocialNetwork.UserChannel do
  use Phoenix.Channel

  def join("user:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("user:" <> _private_room_id, _params, socket) do
    {:ok, "Joined successfully", socket}
  end

  # def handle_in("new_msg", %{"body" => body}, socket) do
  #   broadcast! socket, "new_msg", %{body: body}
  #   {:noreply, socket}
  # end

  # def handle_out("new_msg", payload, socket) do
  #   push socket, "new_msg", payload
  #   {:noreply, socket}
  # end
end