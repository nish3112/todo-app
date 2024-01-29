defmodule TodoAppFull.Repo do
  use Ecto.Repo,
    otp_app: :todo_app_full,
    adapter: Ecto.Adapters.Postgres

end
