defmodule TodoAppFull.Roles do
  alias TodoAppFull.Roles.Role
  alias TodoAppFull.Repo

  @moduledoc """
  The TodoAppFull.Roles module handles roles within the TodoAppFull application,
  allowing the retrieval of all roles from the database and the creation of new roles with specified attributes.
  It offers functions to fetch all roles and to create new roles by providing attributes such as the role name.
  """


@doc """
  Fetches all roles from the database.

  ## Examples

      iex> TodoAppFull.Roles.fetch_roles()
      [%Role{}, ...]
  """
  def fetch_roles do
    Repo.all(Role)
  end


  @doc """
  Creates a new role with the provided attributes.

  ## Parameters
    * `attrs` - A map containing the attributes for the new role.

  ## Examples

      iex> TodoAppFull.Roles.create_role(%{role: "Creator"})
      {:ok, %Role{...}}
  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  # ADD get_role_by_id, get_role_by_name, delete role

end
