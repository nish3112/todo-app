defmodule TodoAppFullWeb.TodoLive.Show do

  use TodoAppFullWeb, :live_view


  @impl true
  def mount(params, session, socket) do
    %{"id" => id} = params

    current_user = TodoAppFull.Accounts.get_user_by_session_token(session["user_token"])
    permission = TodoAppFull.Permissions.check_permission(current_user.id, id)
    IO.inspect(permission, label: "PERMISSION")

    updated_socket = socket
                      |> assign(:current_user, current_user)
                      |> assign(:permission, permission || "Unauthorized")

                      |> assign( :selected_subtask, %TodoAppFull.Subtasks.Subtask{})
    {:ok, updated_socket}

  end


  @impl true
  def handle_params(params, _, socket) do

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


  defp apply_action(socket, :show, params) do
    %{"id" => id} = params

    if socket.assigns.permission == nil || socket.assigns.permission == "Unauthorized" do
      socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
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

  defp apply_action(socket, :permissions, _params) do

    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))

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


  def handle_event("shareSubtodos", _, socket) do
    {:noreply, assign(socket, live_action: :permissions)}
  end

  def handle_event("grant_permission", %{"role_id" => role_id, "user_email" => user_email}, socket) do

    user_id = fetch_user_id(user_email)
    IO.inspect(user_id, label: "User ID")
    IO.inspect(role_id, label: "Role-id")
    IO.inspect(socket.assigns.todo.id, label: "Todo-id")
    TodoAppFull.Permissions.create_or_update_permission(user_id,socket.assigns.todo.id,role_id)

    IO.inspect("OKK")

    {:noreply, socket}
  end


  def handle_event("remove_permission", %{"id" => permission_id}, socket) do
    IO.inspect(permission_id, label: "Permission deleted for id : ")
    TodoAppFull.Permissions.remove_permission(permission_id)
    IO.inspect("Permission removed")
    {:noreply, socket}
  end



  def handle_event("save-inline", todo_params, socket) do

    get_subtask = TodoAppFull.Subtasks.get_subtask!(todo_params["selected_subtask_id"])
    updated_todo_params = Map.delete(todo_params, "selected_subtask_id")

    case TodoAppFull.Subtasks.update_subtask(get_subtask, updated_todo_params) do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        {:noreply,
         socket
         |> put_flash(:info, "Todo updated successfully")
      }

      {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
    end

  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp fetch_user_id(user_email) do
    user = TodoAppFull.Accounts.get_user_by_email(user_email)
    user.id
  end

  defp page_title(:show), do: "Show Todo"
  defp page_title(:sub_edit), do: "Edit Todo"
  defp page_title(:new), do: "New Sub Todo"
  defp page_title(:permissions), do: "Managing permissions"

end
