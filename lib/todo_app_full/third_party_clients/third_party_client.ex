defmodule TodoAppFull.ThirdPartyClients.ThirdPartyClient do
  use Ecto.Schema
  import Ecto.Changeset


  @primary_key {:id, :binary_id, autogenerate: true}

  @moduledoc """
  This module defines the schema for third party clients.
  """

  schema "subtasks" do
    field :client_company_name, :string
    field :client_api_key, :string
    field :balance, :integer
  end

  @doc false
  def changeset(subtask, attrs) do
    subtask
    |> cast(attrs, [:client_company_name, :client_api_key, :balance])
    |> validate_required([:client_company_name, :client_api_key, :balance])
  end
end
