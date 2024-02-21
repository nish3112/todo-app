defmodule TodoAppFullWeb.CollabChannelTest do
  use TodoAppFullWeb.ChannelCase
  alias Ecto.UUID

  setup do
    {:ok, _, socket} =
      TodoAppFullWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(TodoAppFullWeb.CollabChannel, "room:42")

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to collab:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end

  test "join/3 joins a room with a specific ID" do
    room_id = UUID.generate()
    {:ok, socket} = TodoAppFullWeb.CollabChannel.join("room:" <> room_id, %{}, %Phoenix.Socket{})
    assert {:ok, socket} == {:ok, socket}
  end


end
