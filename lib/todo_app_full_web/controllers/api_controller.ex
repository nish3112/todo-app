defmodule TodoAppFullWeb.ApiController do
  alias TodoAppFull.ThirdPartyClients
  use TodoAppFullWeb, :controller

  def index(conn, %{"client_key" => client_key, "user_key" => user_key}) do
    # Check if the client has enough balance
    # Validate this against the db

    # Get the user with the user_key
    # Return the list of todos and subtodos : preloaded to the client
    current_balance = ThirdPartyClients.get_client_balance_by_api_key(client_key)
    if current_balance < 3 do
      json(conn, %{message: "Insufficient Balance. Please top up your account"})
    else

    end

    json(conn, %{message: "Received key1: #{client_key} and key2: #{user_key}"})
  end

  def index(conn, _params) do
    json(conn, %{message: "BAD REQUEST 100"})
  end


  def api_register(conn, _params) do
    render(conn, "api_register.html", layout: false)
  end

end
