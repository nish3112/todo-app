defmodule TodoAppFull.Permissions.Permission do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "permissions" do
    belongs_to :role, TodoAppFull.Roles.Role
    belongs_to :todo, TodoAppFull.Todos.Todo
    belongs_to :user, TodoAppFull.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(permission, attrs) do
    permission
    |> cast(attrs, [:role_id, :todo_id, :user_id])
    |> validate_required([:role_id, :todo_id, :user_id])
  end
end
