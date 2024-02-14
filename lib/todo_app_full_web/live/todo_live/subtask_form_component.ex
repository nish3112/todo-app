defmodule TodoAppFullWeb.TodoLive.SubtaskFormComponent do

  use TodoAppFullWeb, :live_component

@impl true
def render(assigns) do
  ~H"""
  <div>


    <.simple_form
      for={@subtaskForm}
      id="subtask-form"
      phx-target={@myself}
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@subtaskForm[:title]} type="text" label="Title" phx-debounce="500"/>
      <.input field={@subtaskForm[:body]} type="text" label="Body" phx-debounce="500"/>
      <.input field={@subtaskForm[:status]} type="select"options={[{"in-progress", "in-progress"}, {"completed", "completed"}, {"on-hold", "on-hold"}]} label="Status"/>

      <:actions>
        <.button phx-disable-with="Saving...">Save Todo</.button>
      </:actions>
    </.simple_form>
  </div>
  """
end


@impl true
def update(%{subtask: subtask} = assigns, socket) do
  # IO.inspect(assigns, label: "Assigns of update")
  # IO.inspect(subtask)
  changeset = TodoAppFull.Subtasks.change_subtask(subtask)

  {:ok,
   socket
   |> assign(assigns)
   |> assign_form(changeset)}
end

@impl true
  def handle_event("validate", %{"subtask" => subtask_params}, socket) do
    subtask_params = Map.put(subtask_params, "todo_id", socket.assigns.todo.id)
    changeset =
      socket.assigns.subtask
      |> TodoAppFull.Subtasks.change_subtask(subtask_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subtask" => subtask_params}, socket) do
    new_subtask_params = Map.put(subtask_params, "todo_id", socket.assigns.id)
    save_todo(socket, socket.assigns.action, new_subtask_params)
  end


  defp save_todo(socket, :sub_edit, subtask_params) do
      current_subtask = TodoAppFull.Subtasks.get_subtask!(socket.assigns.subtask.id)
      IO.inspect(subtask_params)
      case TodoAppFull.Subtasks.update_subtask(current_subtask, subtask_params) do
        {:ok, todo} ->
          notify_parent({:saved, todo})

          {:noreply,
           socket
           |> put_flash(:info, "Subtask created successfully")
           |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
  end

  defp save_todo(socket, :new, subtask_params) do
    case TodoAppFull.Subtasks.create_subtask(subtask_params) do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        {:noreply,
         socket
         |> put_flash(:info, "Subtask created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end



defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  assign(socket, :subtaskForm, to_form(changeset))
end


defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

end
