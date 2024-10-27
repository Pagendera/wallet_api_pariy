defmodule WalletApiPariyWeb.TransactionJSON do
  alias WalletApiPariy.Transactions.Transaction

  @doc """
  Renders a list of transactions.
  """
  def index(%{transactions: transactions}) do
    %{data: for(transaction <- transactions, do: data(transaction))}
  end

  @doc """
  Renders a single transaction.
  """
  def create_bet(%{transaction: transaction}) do
    data(transaction)
  end

  defp data(%Transaction{} = transaction) do
    user = transaction.user

    %{
      user: user.name,
      currency: user.currency,
      balance: user.balance
    }
  end
end
