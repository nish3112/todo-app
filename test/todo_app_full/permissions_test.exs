defmodule TodoAppFull.PermissionsTest do
  use ExUnit.Case
  alias TodoAppFull.Roles
  alias TodoAppFull.Roles.Role
  alias TodoAppFull.Repo
  use TodoAppFull.DataCase
  alias TodoAppFull.Permissions

  # role, todo, user

  setup do
    todo = TodoAppFull.TodosFixtures.todo_fixture()
    user = TodoAppFull.AccountsFixtures.user_fixture()
    user2 = TodoAppFull.AccountsFixtures.user_fixture()

    {:ok, %{todo: todo, user: user, user2: user2}}
  end


  test "get_permission/2 retrieves the permission for a given user and todo" ,  %{todo: todo, user: user} do
    {:ok, role} = Roles.create_role(%{role: "Test Role"})
    {:ok, _permission} = TodoAppFull.Permissions.create_permission(user.id, todo.id, role.id)
    permission = TodoAppFull.Permissions.get_permission(user.id, todo.id)
    assert permission != nil

  end

  test "check_permission/2 checks the type of permission allotted to a user for a specific todo", %{todo: todo, user: user} do
    {:ok, role} = Roles.create_role(%{role: "Test Role"})
    {:ok, _permission} = TodoAppFull.Permissions.create_permission(user.id, todo.id, role.id)
    permission_type = TodoAppFull.Permissions.check_permission(user.id, todo.id)
    assert role.role == permission_type
  end

  #  CHECK CREATE AND UPDATE IT RETURNS A LIST IN HERE
  # test "create_or_update_permission/3 creates or updates the permission based on the existing permission", %{todo: todo, user: user} do
  #   {:ok, role1} = Roles.create_role(%{role: "Test Role 1"})
  #   {:ok, role2} = Roles.create_role(%{role: "Test Role 2"})

  #   # Create permission
  #   {:ok, permission1} = Permissions.create_or_update_permission(user.id, todo.id, role1.id)
  #   assert role1.id == permission1.role_id

  #   # Update permission
  #   {:ok, permission2} = Permissions.create_or_update_permission(user.id, todo.id, role2.id)
  #   assert role2.id == permission2.role_id
  # end

  test "remove_permission/1 removes the permission with the given permission_id", %{todo: todo, user: user} do
    {:ok, role} = Roles.create_role(%{role: "Test Role"})
    {:ok, permission} = Permissions.create_permission(user.id, todo.id, role.id)

    assert Repo.get(Permissions.Permission, permission.id) != nil

    Permissions.remove_permission(permission.id)
    assert Repo.get(Permissions.Permission, permission.id) == nil
  end

  test "list_permissions_for_todo/1 lists all permissions for the given todo_id", %{todo: todo, user: user, user2: user2} do
    {:ok, role1} = Roles.create_role(%{role: "Test Role 1"})
    {:ok, role2} = Roles.create_role(%{role: "Test Role 2"})

    {:ok, _permission1} = Permissions.create_permission(user.id,todo.id,role1.id)
    {:ok, _permission2} = Permissions.create_permission(user2.id,todo.id,role2.id)

    permissions = Permissions.list_permissions_for_todo(todo.id)
    assert length(permissions) == 2
  end
end
