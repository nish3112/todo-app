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

  def create_permission(user_id, todo_id, role_id) do
    changeset = Permission.changeset(%Permission{}, %{user_id: user_id, todo_id: todo_id, role_id: role_id})

    case Repo.insert(changeset) do
      {:ok, permission} -> {:ok, permission}
      {:error, changeset} -> {:error, changeset}
    end
  end





end
