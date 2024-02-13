defmodule TodoAppFull.Permissions do
  @moduledoc """
  The Permissions context.
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

  def create_or_update_permission(user_id, todo_id, role_id) do
    case Repo.get_by(Permission, user_id: user_id, todo_id: todo_id) do
      nil ->
        create_permission(user_id, todo_id, role_id)

      permission ->
        update_permission(permission, role_id)
    end
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


  def remove_permission(permission_id) do
    permission = Repo.get!(Permission, permission_id)
    Repo.delete(permission)
  end


  def list_permissions_for_todo(todo_id) do
    Repo.all(from p in Permission,
             where: p.todo_id == ^todo_id,
             preload: [:user, :role])
  end




end
