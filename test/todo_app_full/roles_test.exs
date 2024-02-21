defmodule TodoAppFull.RolesTest do
  use ExUnit.Case
  alias TodoAppFull.Roles
  alias TodoAppFull.Roles.Role
  alias TodoAppFull.Repo
  use TodoAppFull.DataCase

  test "fetch_roles returns an empty list when there are no roles" do
    roles = Roles.fetch_roles()
    assert Enum.empty?(roles)
  end


  test "fetch_roles returns all roles after inserting data and checks if they are the same" do
    roles_to_insert = [
      %Role{role: "Creator1"},
      %Role{role: "Editor1"},
      %Role{role: "Viewer1"}
    ]
    Enum.each(roles_to_insert, &Repo.insert!(&1))
    roles = Roles.fetch_roles()

    assert length(roles) == length(roles_to_insert)
    assert Enum.all?(roles, fn role -> role.role in ["Creator1", "Editor1", "Viewer1"] end)
  end

  test "fetch_roles returns all roles after inserting data if they are not the same" do
    roles_to_insert = [
      %Role{role: "TEST ROLE"},
      %Role{role: "Editor1"},
      %Role{role: "Viewer1"}
    ]
    Enum.each(roles_to_insert, &Repo.insert!(&1))
    roles = Roles.fetch_roles()

    assert length(roles) == length(roles_to_insert)
    refute Enum.all?(roles, fn role -> role.role in ["Creator1", "Editor1", "Viewer1"] end)
  end


end
