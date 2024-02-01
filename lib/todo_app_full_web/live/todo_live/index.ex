defmodule TodoAppFullWeb.TodoLive.Index do
  alias TodoAppFull.Accounts
  use TodoAppFullWeb, :live_view

  alias TodoAppFull.Todos
  alias TodoAppFull.Todos.Todo

  @impl true
  def mount(_params, session, socket) do
    socket = assign(socket, bookmark: false)
    socket = assign(socket, session_id: session["user_token"])
    {:ok, stream(socket, :todos, [])}
  end

  @impl true
  @spec handle_params(any(), any(), %{
          :assigns => atom() | %{:live_action => :edit | :index | :new, optional(any()) => any()},
          optional(any()) => any()
        }) :: {:noreply, map()}


  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    socket
    |> assign(:page_title, "Listing Todos")
    |> stream(:todos, todos, reset: true)

  end

  @impl true
  def handle_info({TodoAppFullWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    {:noreply, stream_insert(socket, :todos, todo)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end


  @impl true
  def handle_event("search", %{"title" => title}, socket) do

    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    filtered_todos = Enum.filter(todos, fn todo ->
      String.downcase(todo.title) |> String.contains?(String.downcase(title))
    end)
    {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
  end

  @impl true
  def handle_event("togglelike", %{"todo_id" => todo_id}, socket) do
    todo = TodoAppFull.Todos.get_todo!(todo_id)
    updated_attrs = %{"liked" => !todo.liked}
    {:ok, updated_todo} = TodoAppFull.Todos.update_todo(todo, updated_attrs)

    {:noreply, stream_insert(socket, :todos, updated_todo)}
  end


  @impl true
  def handle_event("bookmark", _params, socket) do
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    is_bookmark = socket.assigns[:bookmark]
    bookmark_todos = Enum.filter(todos, fn todo -> todo.liked == true end)

    if is_bookmark == false  do
      socket = assign(socket, bookmark: !is_bookmark)
      {:noreply, stream(socket, :todos, bookmark_todos, reset: true)}
    else
      socket = assign(socket, bookmark: !is_bookmark)
      {:noreply, stream(socket, :todos, todos, reset: true)}

    end


  end

end
