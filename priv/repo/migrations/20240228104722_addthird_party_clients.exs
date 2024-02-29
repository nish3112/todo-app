defmodule TodoAppFull.Repo.Migrations.AddthirdPartyClients do
  use Ecto.Migration

  def change do
    create table(:third_party_clients, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :client_company_name, :text
      add :client_api_key, :text
      add :balance, :integer
    end
  end
end
