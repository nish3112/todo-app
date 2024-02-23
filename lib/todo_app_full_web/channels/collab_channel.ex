defmodule TodoAppFullWeb.CollabChannel do
  use TodoAppFullWeb, :channel

  @impl true

  def join("room:42", _params, socket) do
    {:ok, socket}
  end

  def join("room:" <> private_room_id, _params, socket) do
    IO.inspect(private_room_id, label: "ROOM")
    {:ok, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end


  def handle_in("new_message", %{"field" => field, "value" => value}, socket) do
    # Handle the new message based on the field it pertains to
    broadcast(socket, "new_message", %{"field" => field, "value" => value})
    {:noreply, socket}
  end


  def handle_event("new_message", %{"body" => body}, socket) do
    handle_in("new_message", %{"body" => body}, socket)
    {:noreply, socket}
  end


  @impl true
  def handle_out("user_joined", _msg, socket) do
    push(socket, "user_joined", %{})
    {:noreply, socket}
  end

end
