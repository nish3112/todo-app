defmodule TodoAppFull.Roles do
  alias TodoAppFull.Roles.Role
  alias TodoAppFull.Repo

  # Function to fetch all roles from the database
  def fetch_roles do
    Repo.all(Role)
  end

  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  # ADD get_role_by_id, get_role_by_name, delete role

end
