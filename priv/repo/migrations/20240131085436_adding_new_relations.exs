defmodule TodoAppFull.Repo.Migrations.AddingNewRelations do
  use Ecto.Migration

  def change do
      alter table(:todos) do
        add :created_by, :binary_id
      end
  end
end
