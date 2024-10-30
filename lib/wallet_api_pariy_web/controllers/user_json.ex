defmodule WalletApiPariyWeb.UserJSON do
  alias WalletApiPariy.Users.User

  def show_balance(%{user: user}) do
    data_balance(user)
  end

  defp data_balance(%User{} = user) do
    %{
      user: user.name,
      status: "RS_OK",
      currency: user.currency,
      balance: user.balance
    }
  end
end
