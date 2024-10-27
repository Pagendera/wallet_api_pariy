defmodule WalletApiPariy.Repo do
  use Ecto.Repo,
    otp_app: :wallet_api_pariy,
    adapter: Ecto.Adapters.Postgres
end
