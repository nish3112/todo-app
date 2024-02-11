defmodule TodoAppFullWeb.TodoLive.Show do

  use TodoAppFullWeb, :live_view


  @impl true
  def mount(params, session, socket) do
    %{"id" => id} = params

    current_user = TodoAppFull.Accounts.get_user_by_session_token(session["user_token"])
    permission = TodoAppFull.Permissions.check_permission(current_user.id, id)

    updated_socket = socket
                      |> assign(:current_user, current_user)
                      |> assign(:permission, permission)
                      |> assign( :selected_subtask, %TodoAppFull.Subtasks.Subtask{})
    {:ok, updated_socket}

  end


  @impl true
  def handle_params(params, _, socket) do

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end




  # defp apply_action(socket, :show, params) do
  #   %{"id" => id} = params
  #   socket
  #   |> assign(:page_title, page_title(socket.assigns.live_action))
  #   |> assign(:todo, Todos.get_todo!(id))
  #   |> stream(:subtasks, Todos.get_todo!(id).subtasks)


  # end
  defp apply_action(socket, :show, params) do
    %{"id" => id} = params

    if socket.assigns.permission == nil do
      socket
        |> assign(:permission, "Unauthorized")
        |> assign(:todo, %TodoAppFull.Todos.Todo{})
        |> stream(:subtasks, [])
    else
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:todo, TodoAppFull.Todos.get_todo!(id))
      |> stream(:subtasks, TodoAppFull.Todos.get_todo!(id).subtasks)
    end


  end



  defp apply_action(socket, :new, _params) do

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, %TodoAppFull.Subtasks.Subtask{})

  end

  defp apply_action(socket, :sub_edit, params) do
    %{"task_id" => task_id} = params
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, TodoAppFull.Subtasks.get_subtask!(task_id))
  end



  @impl true
  def handle_event("delete", %{"subtask-id" => subtask_id}, socket) do
    subtask = TodoAppFull.Subtasks.get_subtask!(subtask_id)
    TodoAppFull.Subtasks.delete_subtask(subtask)
    all_subtasks = TodoAppFull.Subtasks.list_subtasks(socket.assigns.todo.id)

    {:noreply, stream(socket, :subtasks, all_subtasks, reset: true)}

  end


  def handle_event("show_todo", %{"todo-id" => subtask_id}, socket) do
    IO.inspect(subtask_id)
    sub_task = TodoAppFull.Subtasks.get_subtask!(subtask_id)
    {:noreply, assign(socket, :selected_subtask, sub_task)}
  end


  def handle_event("lock", _params, socket) do
    IO.inspect("LOCKED/UNLOCKED")

   {:noreply,
    socket |> put_flash(:info, "Todo locked successfully")
    }
  end


  def handle_event("shareSubtodos", _, socket) do
    {:noreply, assign(socket, live_action: :permissions)}
  end



  defp page_title(:show), do: "Show Todo"
  defp page_title(:sub_edit), do: "Edit Todo"
  defp page_title(:new), do: "New Sub Todo"

end
