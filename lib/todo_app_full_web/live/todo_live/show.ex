defmodule TodoAppFullWeb.TodoLive.Show do
  use TodoAppFullWeb, :live_view


  @impl true
  def mount(params, session, socket) do
    %{"id" => id} = params


    Phoenix.PubSub.subscribe(TodoAppFull.PubSub, id)
    IO.inspect("Joined pubsub : " <> id)


    current_user = TodoAppFull.Accounts.get_user_by_session_token(session["user_token"])
    permission = TodoAppFull.Permissions.check_permission(current_user.id, id)
    updated_socket = socket
                      |> assign(:current_user, current_user)
                      |> assign(:permission, permission || "Unauthorized")
                      |> assign(:id, id)
                      |> assign( :selected_subtask, %TodoAppFull.Subtasks.Subtask{})

    {:ok, updated_socket}

  end


  @impl true
  def handle_info({:delete_subtask, subtask}, socket) do
    {:noreply, socket |> stream_delete(:subtasks, subtask)}

  end

  def handle_info({:update_subtask, subtask}, socket) do
    {:noreply, socket |> stream_insert(:subtasks, subtask)}

  end

def handle_info({:saved, todo}, socket) do
    {:noreply, socket |> stream_insert(:subtasks, todo)}
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
      #  You are not using this function for edit 90% --> Confirm this
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
    Phoenix.PubSub.broadcast(TodoAppFull.PubSub, socket.assigns.id,{:delete_subtask, subtask})
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


  def handle_event("save-inline", todo_params, socket) do
    get_subtask = TodoAppFull.Subtasks.get_subtask!(todo_params["selected_subtask_id"])
    updated_todo_params = Map.delete(todo_params, "selected_subtask_id")
    case TodoAppFull.Subtasks.update_subtask(get_subtask, updated_todo_params) do
      {:ok, subtask} ->
        Phoenix.PubSub.broadcast(TodoAppFull.PubSub, socket.assigns.id,{:update_subtask, subtask})

        {:noreply,
         socket
         |> put_flash(:info, "Subtask updated successfully")
      }

      {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
    end
  end


  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end


  defp page_title(:show), do: "Show Todo"
  defp page_title(:sub_edit), do: "Edit Todo"
  defp page_title(:new), do: "New Sub Todo"
  defp page_title(:permissions), do: "Managing permissions"

end
