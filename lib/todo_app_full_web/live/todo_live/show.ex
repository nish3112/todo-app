defmodule TodoAppFullWeb.TodoLive.Show do

  use TodoAppFullWeb, :live_view

  alias TodoAppFull.Todos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # def mount(_params, _session, socket) do
  #   changeset = TodoAppFull.Subtasks.Subtask.changeset(%TodoAppFull.Subtasks.Subtask{}, %{})
  #   new_socket = assign(socket, :form, to_form(changeset))
  #   IO.inspect(new_socket, label: "HEllo")
  #   {:ok, new_socket}
  # end



  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end




  defp apply_action(socket, :show, params) do
    %{"id" => id} = params
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:todo, Todos.get_todo!(id))
    |> stream(:subtasks, Todos.get_todo!(id).subtasks)
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
    {:noreply, socket}
    # {:noreply, stream(socket, :subtasks, [], reset: true)}

  end


  defp page_title(:show), do: "Show Todo"
  defp page_title(:sub_edit), do: "Edit Todo"
  defp page_title(:new), do: "New Sub Todo"

end
