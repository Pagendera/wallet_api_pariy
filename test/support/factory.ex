defmodule WalletApiPariy.Factory do
  use ExMachina.Ecto, repo: WalletApiPariy.Repo

  def user_factory do
    %WalletApiPariy.Users.User{
      name: sequence(:name, &"User #{&1}"),
      balance: 1000,
      currency: "EUR"
    }
  end
end
