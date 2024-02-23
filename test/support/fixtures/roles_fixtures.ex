defmodule TodoAppFull.RolesFixtures do
  alias TodoAppFull.{Roles, Repo}


  def insert_roles do
    roles = [
      %{role: "Creator"},
      %{role: "Editor"},
      %{role: "Viewer"}
    ]

    Repo.transaction(fn ->
      Enum.each(roles, &Roles.create_role/1)
    end)

    Roles.fetch_roles()
  end
end
