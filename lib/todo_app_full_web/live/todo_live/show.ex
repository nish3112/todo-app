defmodule TodoAppFullWeb.TodoLive.Show do
  use TodoAppFullWeb, :live_view
  require Logger

  @moduledoc """
  This module `TodoAppFullWeb.TodoLive.Show` manages the LiveView component responsible for displaying and managing todos and subtodos within the TodoAppFull application.

  ## Responsibilities

  - Mounting: Handles the initial setup and subscription to the appropriate PubSub channel.
  - Handling Params: Manages parameters passed to the LiveView component.
  - Handling Events: Responds to user-triggered events such as subtask deletion, subtask updates, and permission management.
  - Logging: Utilizes the Logger module to log important events and actions performed by users.

  """

  on_mount {TodoAppFullWeb.UserAuth, :mount_current_user}


  @impl true
  def mount(params, session, socket) do
    %{"id" => id} = params
    Phoenix.PubSub.subscribe(TodoAppFull.PubSub, id)
    Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} joined the default room")
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
  @spec handle_info(
          {:delete_subtask, any()} | {:saved, any()} | {:update_subtask, any()},
          Phoenix.LiveView.Socket.t()
        ) :: {:noreply, map()}

  # Handles the deletion of a subtask and updates the LiveView.
  def handle_info({:delete_subtask, subtask}, socket) do
    {:noreply, socket |> stream_delete(:subtasks, subtask)}

  end

  # Handles the update of a subtask and updates the LiveView.
  def handle_info({:update_subtask, subtask}, socket) do
    {:noreply, socket |> stream_insert(:subtasks, subtask)}

  end

  # Handles the saving of a todo and updates the LiveView.
  def handle_info({:saved, todo}, socket) do
      {:noreply, socket |> stream_insert(:subtasks, todo)}
  end

  # HANDLE PERMISSION INFO :permission
  # LISTEN PUBSUB FOR CHANNEL TODO.ID -> bydefault unauthorized

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # Handles the action for showing a todo, either granting or denying access based on permissions.
  defp apply_action(socket, :show, params) do
    %{"id" => id} = params
    if socket.assigns.permission == nil || socket.assigns.permission == "Unauthorized" do
      Appsignal.Logger.warning("Subtask Page - show","User #{socket.assigns.current_user.id} opened the todo: #{id} and was denied access")
      socket
        |> assign(:page_title, page_title(socket.assigns.live_action))
        |> assign(:todo, %TodoAppFull.Todos.Todo{})
        |> stream(:subtasks, [])
    else
      Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} opened the todo: #{id} and was granted access")
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:todo, TodoAppFull.Todos.get_todo!(id))
      |> stream(:subtasks, TodoAppFull.Todos.get_todo!(id).subtasks)
    end
  end

  # Handles the action for opening a new subtask modal.
  defp apply_action(socket, :new, _params) do
    Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} opened new subtask modal")
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, %TodoAppFull.Subtasks.Subtask{})
  end

  # Handles the action for opening an edit subtask modal.
  defp apply_action(socket, :sub_edit, params) do
    %{"task_id" => task_id} = params
    Appsignal.Logger.info("Subtask Page - show", "User#{socket.assigns.current_user.id} opened edit subtask modal (subtask id: #{task_id}) ")

    #  You are not using this function for edit 90% --> Confirm this
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:subtask, TodoAppFull.Subtasks.get_subtask!(task_id))
  end

  # Handles the action for opening an edit permissions modal.
  defp apply_action(socket, :permissions, _params) do
    Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} opened edit permissions modal ")
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
  end


  @impl true
  @doc """
  Handles various events triggered by the user.

  - For the 'delete' event:
      * Deletes the specified subtask.
      * Broadcasts the deletion event to subscribers.
      * Retrieves all subtasks associated with the todo.
      * Streams the updated list of subtasks to the client.

  - For the 'show_todo' event:
      * Retrieves the selected subtask by its ID.
      * Assigns the selected subtask to the socket.

  - For the 'shareSubtodos' event:
      * Assigns the live action to 'permissions', indicating the user's intent to manage permissions.

  - For the 'save-inline' event:
      * Retrieves the specified subtask by its ID.
      * Updates the subtask with the provided parameters.
      * Broadcasts the update event if successful, or assigns the appropriate changeset errors.

  @param event The name of the event triggered by the user.
  @param params Additional parameters passed with the event.
  @param socket The current socket.

  @return A tuple indicating the action to take and the updated socket.
  """

  def handle_event("delete", %{"subtask-id" => subtask_id}, socket) do
    Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} deleted the subtask id: #{subtask_id}")
    subtask = TodoAppFull.Subtasks.get_subtask!(subtask_id)
    TodoAppFull.Subtasks.delete_subtask(subtask)
    Phoenix.PubSub.broadcast(TodoAppFull.PubSub, socket.assigns.id,{:delete_subtask, subtask})
    all_subtasks = TodoAppFull.Subtasks.list_subtasks(socket.assigns.todo.id)
    {:noreply, stream(socket, :subtasks, all_subtasks, reset: true)}
  end


  def handle_event("show_todo", %{"todo-id" => subtask_id}, socket) do
    sub_task = TodoAppFull.Subtasks.get_subtask!(subtask_id)
    Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} clicked on the subtask id: #{subtask_id}")
    {:noreply, assign(socket, :selected_subtask, sub_task)}
  end


  def handle_event("shareSubtodos", _, socket) do
    {:noreply, assign(socket, live_action: :permissions)}
  end


  def handle_event("save-inline", todo_params, socket) do
    Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} is trying to save the subtask id: #{todo_params["selected_subtask_id"]}")
    get_subtask = TodoAppFull.Subtasks.get_subtask!(todo_params["selected_subtask_id"])
    updated_todo_params = Map.delete(todo_params, "selected_subtask_id")
    case TodoAppFull.Subtasks.update_subtask(get_subtask, updated_todo_params) do
      {:ok, subtask} ->
        Phoenix.PubSub.broadcast(TodoAppFull.PubSub, socket.assigns.id,{:update_subtask, subtask})
        Appsignal.Logger.info("Subtask Page - show","User #{socket.assigns.current_user.id} saved the subtask id: #{todo_params["selected_subtask_id"]}")
        {:noreply,
         socket
         |> put_flash(:info, "Subtask updated successfully")
      }

      {:error, %Ecto.Changeset{} = changeset} ->
          Appsignal.Logger.error("Subtask Page - show","User #{socket.assigns.current_user.id} was not able to save the subtask id: #{todo_params["selected_subtask_id"]}")
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
