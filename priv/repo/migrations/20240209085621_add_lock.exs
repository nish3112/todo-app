defmodule TodoAppFull.Repo.Migrations.AddLock do
  use Ecto.Migration

  def change do
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :role, :string
    end

    create table(:permissions, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :todo_id, references(:todos, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :role_id, references(:roles, on_delete: :delete_all, type: :binary_id)
      timestamps()
    end
  end
end
