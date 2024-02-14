defmodule TodoAppFullWeb.TodoLive.FormComponent do
  alias TodoAppFull.Roles
  alias TodoAppFull.Permissions
  alias TodoAppFull.Accounts
  alias TodoAppFull.Todos
  use TodoAppFullWeb, :live_component



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
  def update(%{todo: todo} = assigns, socket) do
    changeset = Todos.change_todo(todo)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    # IO.inspect(todo_params, label: "xyz")
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

  # defp save_todo(socket, :new, todo_params) do
  #   case Todos.create_todo(todo_params) do
  #     {:ok, todo} ->
  #       notify_parent({:saved, todo})

  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "Todo created successfully")
  #        |> push_patch(to: socket.assigns.patch)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign_form(socket, changeset)}
  #   end
  # end

  defp save_todo(socket, :new, todo_params) do
    current_user_id = Accounts.get_user_by_session_token(socket.assigns.current_user).id
    roles = Roles.fetch_roles()

    case Enum.find(roles, fn role -> role.role == "Creator" end) do
      nil ->
        {:noreply, socket |> put_flash(:error, "Some error occuured")}

      creator_role ->
        IO.inspect(creator_role)
        case Todos.create_todo(todo_params) do
          {:ok, todo} ->
            # Notify parent process
            notify_parent({:saved, todo})

            # Create a creator permission
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
