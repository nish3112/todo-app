defmodule TodoAppFullWeb.TodoLive.Index do
  require Logger
  alias TodoAppFull.Categories
  alias TodoAppFull.Accounts
  alias TodoAppFull.Todos
  alias TodoAppFull.Todos.Todo
  use TodoAppFullWeb, :live_view

  on_mount {TodoAppFullWeb.UserAuth, :mount_current_user}

 @moduledoc """
  This module `TodoAppFullWeb.TodoLive.Index` serves as the LiveView controller for the TodoAppFull application's home page.
  It orchestrates the user interface and functionality related to listing, creating, editing, and deleting todo items.

  ## Responsibilities

  - Todo Management: Provides functionalities for listing todos, creating new todos, editing existing todos, and deleting todos.
  - User Interaction: Handles user interactions such as todo searching, toggling todo likes, bookmarking todos, and navigating through todo pages.
  - Event Handling: Manages events triggered by user actions and updates the LiveView state accordingly.
  - Logging: Utilizes the Logger module to log important events and actions performed by users.
  """


  @impl true
  def mount(_params, session, socket) do
    Appsignal.Logger.info("Index Page", "User #{socket.assigns.current_user.id} visited the home page")
    categories = Categories.list_categories()
    socket =  socket
              |> assign(bookmark: false)
              |> assign(session_id: session["user_token"])
              |> assign(page_number: 0)
              |> assign(categories: categories)
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


  # Applies the 'edit' action to the socket.
  # Prepares the socket for editing a todo based on the provided todo ID.
  defp apply_action(socket, :edit, %{"id" => id}) do
    Appsignal.Logger.info("Index Page", "User: #{socket.assigns.current_user.id} edited a todo: #{id}")
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id))

  end

  # Applies the 'new' action to the socket.
  # Prepares the socket for creating a new todo.
  defp apply_action(socket, :new, _params) do
    Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} created a new todo")
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  # Applies the 'index' action to the socket.
  # Prepares the socket for listing todos.
  defp apply_action(socket, :index, _params) do
    Appsignal.Logger.info("Index Page", "User#{socket.assigns.current_user.id} visited the home page :index")
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    {sorted_todos, socket} = paginate_and_sorted_todos(todos, socket)

    socket
    |> assign(:page_title, "Listing Todos")
    |> stream(:todos, sorted_todos, reset: true)
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

  @doc """
    Handles incoming events.

    This function dispatches incoming events to their respective handlers based on the event type.
    The following events are supported:

    - `"delete"`: Deletes the specified todo.
    - `"search"`: Searches for todos based on the provided title.
    - `"togglelike"`: Toggles the liked status of a todo.
    - `"bookmark"`: Handles bookmarking/unbookmarking of todos.
    - `"next"`: Handles pagination for the next page of todos.
    - `"previous"`: Handles pagination for the previous page of todos.
    - `"sortTodos"`: Handles sorting of todos based on status, category, or both.

    Each event handler performs specific actions corresponding to the event type and updates the socket accordingly.

    Parameters:
      - `event`: The type of event being handled.
      - `payload`: The payload associated with the event.
      - `socket`: The current socket state.

    Returns:
      A tuple `{:noreply, updated_socket}` indicating the updated socket state.
   """
  def handle_event("delete", %{"id" => id}, socket) do
    Appsignal.Logger.info("Index Page", "User #{socket.assigns.current_user.id} deleted the todo: #{id}")
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)
    {:noreply, stream_delete(socket, :todos, todo)}
  end

  def handle_event("search", %{"title" => title}, socket) do
    Appsignal.Logger.info("Index Page","User searched for: #{title}")
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    filtered_todos = Enum.filter(todos, fn todo ->
      String.downcase(todo.title) |> String.contains?(String.downcase(title))
    end)
    if String.length(title) == 0 do
      {sorted_todos, socket} = paginate_and_sorted_todos(todos, socket)
      {:noreply, stream(socket, :todos, sorted_todos)}
    else
      {:noreply, stream(socket, :todos, filtered_todos, reset: true)}
    end
  end

  def handle_event("togglelike", %{"todo_id" => todo_id}, socket) do
    Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} liked/unliked the todo: #{todo_id}")
    todo = TodoAppFull.Todos.get_todo!(todo_id)
    updated_attrs = %{"liked" => !todo.liked}
    {:ok, updated_todo} = TodoAppFull.Repo.get_by(TodoAppFull.Todos.Todo, id: todo_id)
                      |>  TodoAppFull.Repo.preload([:category, :subtasks])
                      |>  TodoAppFull.Todos.update_todo(updated_attrs)

    {:noreply, stream_insert(socket, :todos, updated_todo)}
  end

  def handle_event("bookmark", _params, socket) do
    Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} clicked the bookmark")
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    is_bookmark = socket.assigns[:bookmark]
    bookmark_todos = Enum.filter(todos, fn todo -> todo.liked == true end)

    if is_bookmark == false  do
      socket = assign(socket, bookmark: !is_bookmark)
      {:noreply, stream(socket, :todos, bookmark_todos, reset: true)}
    else
      socket = assign(socket, bookmark: !is_bookmark)
      socket = assign(socket, page_number: 0)
      {:noreply, stream(socket, :todos, todos |> Enum.sort() |> Enum.reverse() |> Enum.slice(0,8) ,reset: true)}

    end
  end

  def handle_event("next", %{"id" => _temp_pg_no}, socket) do

    update_page_num = socket.assigns.page_number + 1
    if has_more_todos?(socket, update_page_num) do
      Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} moved to the next page: #{update_page_num}")
      updated_socket = assign(socket, page_number: update_page_num)
      pagination_helper(updated_socket)
    else
      {:noreply, socket}
    end
  end


  def handle_event("previous", %{"id" => _temp_pg_no}, socket) do
    update_page_num = socket.assigns.page_number - 1
    if update_page_num < 0 do
      updated_socket = assign(socket, page_number: 0)
      Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} moved to the previous page: 0")
      pagination_helper(updated_socket)
      {:noreply, updated_socket}
    else
      Appsignal.Logger.info("Index Page","User moved to the previous page: #{update_page_num}")
      updated_socket = assign(socket, page_number: update_page_num)
      pagination_helper(updated_socket)
    end
  end

  def handle_event("sortTodos",%{"status" => status}, socket) do
    Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} filtered according to status: #{status}")
    handle_sort_todos(socket, status , nil)
  end

  def handle_event("sortTodos",%{"category" => category}, socket) do
    Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} filtered according to category: #{category}")
    handle_sort_todos(socket, nil ,category)
  end

  def handle_event("sortTodos", %{"category" => category, "status" => status}, socket) do
    Appsignal.Logger.info("Index Page","User #{socket.assigns.current_user.id} filtered according to status: #{status} and category: #{category}")
    handle_sort_todos(socket, status, category)
  end



  # -----------------------------------  Helper functions -------------------------------------------

  # Helper function to determine if there are more todos available for pagination.
  defp has_more_todos?(socket, page_number) do
    Appsignal.Logger.info("Index Page","Helper function - has more todos called")
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    total_todos_count = length(todos)
    current_page_start = page_number * 8
    total_todos_count > current_page_start
  end

  # Helper function to sort and filter todos based on status and category.
  defp handle_sort_todos(socket, status, category) do
    Appsignal.Logger.info("Index Page", "Helper function - handle sort todos called")
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos

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

  # Helper function to filter todos based on status and category.
  defp match_filter(todo, status, category) do
    todo.status == status && todo.category.category_name == category
  end

  # Helper function to paginate and sort todos.
  defp paginate_and_sorted_todos(todos, socket) do
    Appsignal.Logger.info("Index Page","Helper function - paginate and sorted todos called")
    sorted_todos = todos
                  |> Enum.sort_by(&(&1.updated_at), Date)
                  |> Enum.reverse()
                  |> Enum.slice(socket.assigns.page_number * 8, 8)
    {sorted_todos, socket}
  end

  # Helper function to handle pagination.
  defp pagination_helper(socket) do
    Appsignal.Logger.info("Index Page","Helper function - pagination helper called")
    todos = Accounts.get_user_by_session_token(socket.assigns.session_id).todos
    {sorted_todos, socket} = paginate_and_sorted_todos(todos, socket)
    {:noreply, stream(socket,:todos, sorted_todos, reset: true)}
  end

end
