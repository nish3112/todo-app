defmodule TodoAppFullWeb.TodoLive.Index do
  use TodoAppFullWeb, :live_view

  alias TodoAppFull.Todos
  alias TodoAppFull.Todos.Todo

  @impl true
  def mount(_params, _session, socket) do
    # params and session is not needed for now so ignored
    # so we stream the content of :todos and we get all the todos i.e. Todos.list_todos() and send it with a :ok atom
    # IO.inspect(socket)
    #{:ok, stream(socket, :todos, Todos.list_todos())}
    todos = Todos.list_todos()
    IO.inspect(todos)

    {:ok, stream(socket, :todos, todos)}
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
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
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
    todos = Todos.list_todos()
    filtered_todos = Enum.filter(todos, fn todo ->
      String.downcase(todo.title) |> String.contains?(String.downcase(title))
    end)

    # socket
    # |> stream_delete(:todos, Enum.each(todos, fn x -> x end))
    # |> stream_insert(:todos, Enum.each(filtered_todos, fn y -> y end))

    # for todo <- todos do
    #   socket
    #   |> stream_delete(:todos, todo)
    # end

    # for todo <- filtered_todos do
    #   socket
    #   |> stream_insert(:todos, todo)
    # end


    #{:noreply, socket}

    {:noreply, stream(socket, :todos, filtered_todos, reset: true)}

  end

  @impl true
  def handle_event("togglelike", %{"todo_id" => todo_id}, socket) do
    todo = TodoAppFull.Todos.get_todo!(todo_id)
    updated_attrs = %{"liked" => !todo.liked}
    {:ok, _todo} = TodoAppFull.Todos.update_todo(todo, updated_attrs)

    updated_todos = TodoAppFull.Todos.list_todos()
    {:noreply, stream(socket, :todos, updated_todos)}
  end


  @impl true
  def handle_event("bookmark", _params, socket) do
    todos = Todos.list_todos()
    bookmark_todos = Enum.filter(todos, fn todo -> todo.liked == true end)
   |> IO.inspect()
    {:noreply, stream(socket, :todos, bookmark_todos)}
  end

end
