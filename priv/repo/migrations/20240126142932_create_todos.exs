defmodule TodoAppFull.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :body, :string
      add :status, :string
      add :liked, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
