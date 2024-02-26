defmodule TodoAppFullWeb.CollabChannel do
  use TodoAppFullWeb, :channel

  # CHECK THIS

  @impl true
  @doc """
  Joins the default channel.

  If the room ID is "room:42", it allows the socket to join without any additional checks.

  ## Examples

      iex> join("room:42", params, socket)
      {:ok, socket}

  Joins the channel with a private room ID.

  It inspects the private room ID and allows the socket to join.

  ## Examples

      iex> join("room:9cbbf329-5778-4dda-9596-c21294ea5c6a", params, socket)
      {:ok, socket}
  """
  def join("room:42", _params, socket) do
    {:ok, socket}
  end


  @impl true
  def join("room:" <> private_room_id, _params, socket) do
    IO.inspect(private_room_id, label: "ROOM")
    {:ok, socket}
  end

  @impl true
  @doc """
  Handles the 'ping' message.

  It replies with an 'ok' message containing the payload.

  ## Examples

      iex> handle_in("ping", payload, socket)
      {:reply, {:ok, payload}, socket}


  Handles the 'shout' message.

  It broadcasts the 'shout' message with the payload to all connected sockets.

  ## Examples

      iex> handle_in("shout", payload, socket)
      {:noreply, socket}

  Handles the 'new_message' event.

  It broadcasts the 'new_message' event with the specified field and value to all connected sockets.

  ## Examples

      iex> handle_in("new_message", %{"field" => field, "value" => value}, socket)
      {:noreply, socket}
  """
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


  @doc """
  Handles the 'new_message' event.

  It delegates to the `handle_in/3` function for processing.

  ## Examples

      iex> handle_event("new_message", %{"body" => body}, socket)
      {:noreply, socket}
  """
  def handle_event("new_message", %{"body" => body}, socket) do
    handle_in("new_message", %{"body" => body}, socket)
    {:noreply, socket}
  end


  @impl true
  @doc """
  Handles the 'user_joined' event.

  It pushes the 'user_joined' event to all connected sockets.

  ## Examples

      iex> handle_out("user_joined", msg, socket)
      {:noreply, socket}
  """
  def handle_out("user_joined", _msg, socket) do
    push(socket, "user_joined", %{})
    {:noreply, socket}
  end

end
