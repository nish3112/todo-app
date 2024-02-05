defmodule TodoAppFull.Repo.Migrations.AddingCategory do
  use Ecto.Migration

  def change do
    create table(:categories, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :category_name, :string
    end

    alter table(:todos) do
      add :category_id, references(:categories, on_delete: :nothing, type: :binary_id)
    end

  end
end
