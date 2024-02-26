defmodule TodoAppFull.Permissions do
  @moduledoc """
  The Permissions context.
  The TodoAppFull.Permissions module is responsible for managing permissions within the application.
  It facilitates operations such as creating, retrieving, updating, and deleting permissions associated with users and todos.
  Additionally, it offers functionality to check the type of permission granted to a user for a specific todo and to list permissions related to a particular todo.
  """

  import Ecto.Query, warn: false
  alias TodoAppFull.Repo

  alias TodoAppFull.Permissions.Permission

  @doc """
  Retrieves the permission for a given user and todo.

  Returns nil if no permission is found.

  ## Examples

      iex> get_permission(user_id, todo_id)
      %Permission{} | nil
  """
  def get_permission(user_id, todo_id) do
    Repo.get_by(Permission, user_id: user_id, todo_id: todo_id) |> Repo.preload(:role)
  end

  # Implement other CRUD operations as needed (create, update, delete)

  @doc """
  Checks the type of permission allotted to a user for a specific todo.

  Returns a string representing the type of permission (e.g., "creator", "editor", "viewer").

  ## Examples

      iex> check_permission(user_id, todo_id)
      "creator" | "editor" | "viewer" | nil
  """
  def check_permission(user_id, todo_id) do
    case get_permission(user_id, todo_id) do
      %Permission{role: role} -> role.role
      _ -> nil
    end
  end

  @doc """
  Creates or updates a permission record for a user and a todo.

  Returns the permissions associated with the todo after the operation.

  ## Examples

      iex> create_or_update_permission(user_id, todo_id, role_id)
      [%Permission{}, ...] --> Change this
  """

  def create_or_update_permission(user_id, todo_id, role_id) do
    case Repo.get_by(Permission, user_id: user_id, todo_id: todo_id) do
      nil ->
        create_permission(user_id, todo_id, role_id)

      permission ->
        update_permission(permission, role_id)
    end
    list_permissions_for_todo(todo_id)
  end

  def create_permission(user_id, todo_id, role_id) do
    changeset = Permission.changeset(%Permission{}, %{user_id: user_id, todo_id: todo_id, role_id: role_id})
    IO.inspect("Permission created")
    case Repo.insert(changeset) do
      {:ok, permission} -> {:ok, permission}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_permission(permission, role_id) do
    changeset = Permission.changeset(permission, %{role_id: role_id})
    IO.inspect("Permission updated")
    case Repo.update(changeset) do
      {:ok, updated_permission} -> {:ok, updated_permission}
      {:error, changeset} -> {:error, changeset}
    end
  end


  @doc """
  Removes a permission.

  Returns `:ok` upon successful removal.

  ## Examples

      iex> remove_permission(permission_id)
      :ok
  """
  def remove_permission(permission_id) do
    permission = Repo.get!(Permission, permission_id)
    Repo.delete(permission)
  end


  @doc """
  Lists permission associated with a specific todo.

  Returns a list of permissions.

  ## Examples

      iex> list_permissions_for_todo(todo_id)
      [%Permission{}, ...]
  """
  # MAKE IT REPO.ONE --> It will always return be a single permission

  def list_permissions_for_todo(todo_id) do
    Repo.all(from p in Permission,
             where: p.todo_id == ^todo_id,
             preload: [:user, :role])
  end

end
