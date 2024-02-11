defmodule TodoAppFull.Roles do
  alias TodoAppFull.Roles.Role
  alias TodoAppFull.Repo

  # Function to fetch all roles from the database
  def fetch_roles do
    Repo.all(Role)
  end
end
