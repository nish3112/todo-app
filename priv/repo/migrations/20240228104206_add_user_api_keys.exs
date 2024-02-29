defmodule TodoAppFull.Repo.Migrations.AddUserApiKeys do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :api_key, :text
    end
  end
end
