defmodule TodoAppFull.ThirdPartyClients do
  import Ecto.Query, warn: false
  alias TodoAppFull.ThirdPartyClient
  alias TodoAppFull.ThirdPartyClients.ThirdPartyClient


  def get_client_balance_by_api_key(client_api_key) do
    from t in ThirdPartyClient,
      select: t.balance,
      where: t.client_api_key == ^client_api_key
  end


end
