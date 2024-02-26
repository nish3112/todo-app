defmodule TodoAppFullWeb.TodoLive.FormComponent do
  alias TodoAppFull.Roles
  alias TodoAppFull.Permissions
  alias TodoAppFull.Accounts
  alias TodoAppFull.Todos
  use TodoAppFullWeb, :live_component

  @moduledoc """
  This module defines the FormComponent used for managing TODO records.
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage todo records in your database.</:subtitle>
      </.header>
      <.simple_form
        for={@form}
        id="todo-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:body]} type="text" label="Body" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[
            {"in-progress", "in-progress"},
            {"completed", "completed"},
            {"on-hold", "on-hold"}
          ]}
        >
        </.input>
        <.input field={@form[:category_id]} type="select" label="Category" options={@categories}>
        </.input>

        <.input field={@form[:liked]} type="checkbox" label="Liked" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Todo</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end


  @impl true
  @doc """
  Updates the component with the provided assigns.

  ## Parameters
    * `assigns` - A map containing the assigns for the component.
    * `socket` - The current socket.

  ## Examples

      iex> update(assigns, socket)
      {:ok, updated_socket}
  """
  def update(%{todo: todo} = assigns, socket) do
    changeset = Todos.change_todo(todo)
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  @doc """
  Handles the 'validate' event.

  Validates the todo form data and updates the changeset accordingly.

  ## Parameters
    * `todo_params` - A map containing the todo parameters - title, body, status, liked.

  ## Examples

      iex> handle_event("validate", %{"todo" => todo_params}, socket)
      {:noreply, updated_socket}


  Handles the 'save' event.

  Saves the todo data and creates or gives the user who created the todo a creator permission.

  ## Parameters
    * `todo_params` - A map containing the todo parameters.

  ## Examples

      iex> handle_event("save", %{"todo" => todo_params}, socket)
      {:noreply, updated_socket}
  """
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset =
      socket.assigns.todo
      |> TodoAppFull.Repo.preload(:category)
      |> Todos.change_todo(todo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    current_user_id = Accounts.get_user_by_session_token(socket.assigns.current_user).id
    updated_todo_params = Map.put_new(todo_params, "user_id", current_user_id)
    save_todo(socket, socket.assigns.action, updated_todo_params)
  end


  # Handles the saving of todo data when editing an existing todo.
  #
  # This function updates the todo data and notifies the parent component upon successful update.
  # If an error occurs during the update process, it returns an appropriate flash message to the user.
  #
  # Parameters:
  #   - socket: The current socket.
  #   - :edit: Atom indicating the edit action.
  #   - todo_params: A map containing the updated todo parameters.
  #
  # Examples:
  #   save_todo(socket, :edit, %{title: "Updated Title", body: "Updated Body", status: "on-hold", liked: false})
  defp save_todo(socket, :edit, todo_params) do
    dbg(todo_params)
    case Todos.update_todo(socket.assigns.todo, todo_params) do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        {:noreply,
         socket
         |> put_flash(:info, "Todo updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end


  # Handles the saving of todo data when creating a new todo.
  #
  # This function creates a new todo and assigns permission to the creator
  #
  # Parameters:
  #   - socket: The current socket.
  #   - :new: Atom indicating the new todo creation action.
  #   - todo_params: A map containing the new todo parameters.
  #
  # Examples:
  #   save_todo(socket, :new,  %{title: "Updated Title", body: "Updated Body", status: "on-hold", liked: false})
  defp save_todo(socket, :new, todo_params) do
    current_user_id = Accounts.get_user_by_session_token(socket.assigns.current_user).id
    roles = Roles.fetch_roles()

    case Enum.find(roles, fn role -> role.role == "Creator" end) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Some error occuured")}

      creator_role ->
        case Todos.create_todo(todo_params) do
          {:ok, todo} ->
            notify_parent({:saved, todo})

            case Permissions.create_permission(current_user_id, todo.id, creator_role.id) do
              {:ok, _permission} ->
                {:noreply,
                 socket
                 |> put_flash(:info, "Todo created successfully")
                 |> push_patch(to: socket.assigns.patch)}

              {:error, _changeset} ->
                {:noreply, socket |> put_flash(:error, "Failed to create permission")}
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
        end
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
