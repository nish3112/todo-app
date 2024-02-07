defmodule TodoAppFull.Repo.Migrations.SubTaskFields do
  use Ecto.Migration

  def change do
    create table(:subtasks, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :title, :string
      add :body, :string
      add :status, :string

      timestamps(type: :utc_datetime)
    end

  end
end
