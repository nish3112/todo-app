defmodule TodoAppFullWeb.TodoLive.FormComponent do
  alias TodoAppFull.Accounts
  use TodoAppFullWeb, :live_component

  alias TodoAppFull.Todos

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
        <.input field={@form[:status]} type="select" label = "Status"
          options={[{"in-progress", "in-progress"}, {"completed", "completed"}, {"on-hold", "on-hold"}]}>
        </.input>
        <.input field={@form[:category_id]} type="select" label="Category"
         options={@categories}>
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
    IO.inspect(todo_params, label: "xyz")
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

  defp save_todo(socket, :new, todo_params) do
    case Todos.create_todo(todo_params) do
      {:ok, todo} ->
        notify_parent({:saved, todo})

        {:noreply,
         socket
         |> put_flash(:info, "Todo created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
