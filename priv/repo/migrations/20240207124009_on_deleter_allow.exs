defmodule TodoAppFull.Repo.Migrations.OnDeleterAllow do
  use Ecto.Migration

  def up do
    execute "ALTER TABLE subtasks DROP CONSTRAINT subtasks_todo_id_fkey"
    alter table(:subtasks) do
      modify(:todo_id, references(:todos, on_delete: :delete_all, type: :binary_id))
    end
  end

  def down do
    execute "ALTER TABLE subtasks DROP CONSTRAINT subtasks_todo_id_fkey"
    alter table(:subtasks) do
      modify(:todo_id, references(:todos, on_delete: :nothing, type: :binary_id))
    end
  end
end
