defmodule TodoAppFull.Repo.Migrations.AddingNewRelations2 do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      modify :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end
  end
end
