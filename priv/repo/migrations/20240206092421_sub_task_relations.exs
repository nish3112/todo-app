defmodule TodoAppFull.Repo.Migrations.SubTaskRelations do
  use Ecto.Migration

  def change do
    alter table(:subtasks) do
      add :todo_id, references(:todos, on_delete: :nothing, type: :binary_id)
    end

  end
end
