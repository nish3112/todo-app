defmodule TodoAppFullWeb.TodoLive.Index do
  alias TodoAppFull.Categories
  alias TodoAppFull.Accounts
  use TodoAppFullWeb, :live_view

  alias TodoAppFull.Todos
  alias TodoAppFull.Todos.Todo

  @impl true
  def mount(_params, session, socket) do

    categories = Categories.list_categories()
    socket = assign(socket, bookmark: false)
    socket = assign(socket, session_id: session["user_token"])
    socket = assign(socket, page_number: 0)
    socket = assign(socket, categories: categories)
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
    sorted_todos = todos
                  |> Enum.sort_by(&(&1.updated_at), Date)
                  |> Enum.reverse()
                  |> Enum.slice(socket.assigns.page_number * 8, 8)
    socket
    |> assign(:page_title, "Listing Todos")
    |> stream(:todos, sorted_todos, reset: true)


  end

  defp pagination_helper(socket) do
    dbg(socket)
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos

    sorted_todos = todos
                  |> Enum.sort_by(&(&1.updated_at), Date)
                  |> Enum.reverse()
                  |> Enum.slice(socket.assigns.page_number * 8, 8)

    {:noreply, stream(socket,:todos, sorted_todos, reset: true)}

  end



  @impl true
  @spec handle_info(
          {TodoAppFullWeb.TodoLive.FormComponent, {:saved, any()}},
          Phoenix.LiveView.Socket.t()
        ) :: {:noreply, map()}

  def handle_info({TodoAppFullWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    todo = TodoAppFull.Repo.preload(todo, :category)
    {:noreply, stream_insert(socket, :todos, todo, at: 0)}
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

    if String.length(title) == 0 do
      {:noreply, stream(socket, :todos, todos |> Enum.sort() |> Enum.reverse() |> Enum.slice(0,8) ,reset: true)}
    else
      {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
    end


  end

  @impl true
  def handle_event("togglelike", %{"todo_id" => todo_id}, socket) do

    todo = TodoAppFull.Todos.get_todo!(todo_id)
    updated_attrs = %{"liked" => !todo.liked}
    {:ok, updated_todo} = TodoAppFull.Repo.get_by(TodoAppFull.Todos.Todo, id: todo_id)
                        |> TodoAppFull.Repo.preload([:category, :subtasks])
                        |>  TodoAppFull.Todos.update_todo(updated_attrs)


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
      socket = assign(socket, page_number: 0)

      #{:noreply, stream(socket, :todos, todos, reset: true)}
      {:noreply, stream(socket, :todos, todos |> Enum.sort() |> Enum.reverse() |> Enum.slice(0,6) ,reset: true)}

    end

  end

    @impl true
    def handle_event("next", %{"id" => _temp_pg_no}, socket) do
      update_page_num = socket.assigns.page_number + 1

      if has_more_todos?(socket, update_page_num) do
        updated_socket = assign(socket, page_number: update_page_num)
        pagination_helper(updated_socket)
      else
        {:noreply, socket}
      end
    end

    @impl true
    def handle_event("previous", %{"id" => _temp_pg_no}, socket) do

      update_page_num = socket.assigns.page_number - 1

      if update_page_num < 0 do
        updated_socket = assign(socket, page_number: 0)
        pagination_helper(updated_socket)
        {:noreply, updated_socket}
      else
        updated_socket = assign(socket, page_number: update_page_num)
        pagination_helper(updated_socket)

      end
    end


    @impl true
    def handle_event("sortTodos",%{"status" => status}, socket) do
      handle_sort_todos(socket, status , nil)
    end


    @impl true
    def handle_event("sortTodos",%{"category" => category}, socket) do
      handle_sort_todos(socket, nil ,category)
    end


    @impl true
    def handle_event("sortTodos", %{"category" => category, "status" => status}, socket) do
      handle_sort_todos(socket, status, category)
    end



    # -----------------------------------  Helper functions -------------------------------------------

    defp has_more_todos?(socket, page_number) do
      todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
      total_todos_count = length(todos)
      current_page_start = page_number * 8
      total_todos_count > current_page_start
    end

    defp handle_sort_todos(socket, status, category) do
      todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
      IO.inspect(todos)

      filtered_todos =
        case {status, category} do
          {nil, "all"} -> todos
          {"all", nil} -> todos
          {nil, category} -> Enum.filter(todos, &(&1.category.category_name == category))
          {status, nil} -> Enum.filter(todos, &(&1.status == status))
          {status, category} -> Enum.filter(todos, &(match_filter(&1, status, category)))
        end

      {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
    end

      defp match_filter(todo, status, category) do
        todo.status == status && todo.category.category_name == category
      end







end
