defmodule TodoAppFullWeb.TodoLive.SubtaskFormComponent do

  require Logger
  use TodoAppFullWeb, :live_component



  @moduledoc """
  This module `TodoAppFullWeb.TodoLive.SubtaskFormComponent` manages the LiveComponent responsible for rendering and handling subtask forms within the TodoAppFull application.

  ## Responsibilities

  - **Updating**: Manages the update process for the subtask form component, including changeset generation and assignment to the socket.
  - **Handling Events**: Responds to user-triggered events such as validation and saving of subtasks.
  - **Logging**: Utilizes the Logger module to log important events and actions performed by users.

  """


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
  changeset = TodoAppFull.Subtasks.change_subtask(subtask)

  {:ok,
   socket
   |> assign(assigns)
   |> assign_form(changeset)}
end

  @impl true
  @doc """
  Handles validation and saving of subtasks based on user input.

  - For the 'validate' event:
      * Adds the todo_id to the subtask parameters.
      * Generates a changeset for the subtask.
      * Assigns the changeset to the socket for form validation.

  - For the 'save' event:
      * Adds the todo_id to the subtask parameters.
      * Calls the save_todo function to handle the action based on the provided parameters.

  @param event The name of the event triggered by the user.
  @param subtask_params Parameters associated with the subtask.
  @param socket The current socket.

  @return A tuple indicating the action to take and the updated socket.
  """

  def handle_event("validate", %{"subtask" => subtask_params}, socket) do
    Appsignal.Logger.info("Subtask Form","Subtask form validated")
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

  # Handles the saving of a new subtask based on user input.
  defp save_todo(socket, :new, subtask_params) do
    Appsignal.Logger.info("Subtask Form","User is trying to create a new subtask for the : #{subtask_params["todo_id"]}")
    case TodoAppFull.Subtasks.create_subtask(subtask_params) do
      {:ok, todo} ->
        Phoenix.PubSub.broadcast(TodoAppFull.PubSub, socket.assigns.id, {:saved,todo})
        Appsignal.Logger.info("Subtask Form","User created a new subtask for the : #{subtask_params["todo_id"]}")
        {:noreply,
         socket
         |> put_flash(:info, "Subtask created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Appsignal.Logger.error("Subtask Form","User was unable to create a new subtask for the : #{subtask_params["todo_id"]}")
        {:noreply, assign_form(socket, changeset)}
    end
  end



defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  assign(socket, :subtaskForm, to_form(changeset))
end


end
