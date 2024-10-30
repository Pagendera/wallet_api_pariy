defmodule WalletApiPariyWeb.TransactionController do
  use WalletApiPariyWeb, :controller

  alias WalletApiPariy.Transactions
  alias WalletApiPariy.Transactions.Transaction

  action_fallback WalletApiPariyWeb.FallbackController

  def create_bet(conn, transaction_params) do
    with {:ok, %Transaction{} = transaction} <- Transactions.create_bet(transaction_params) do
      conn
      |> render(:create_transaction, transaction: transaction)
    end
  end

  def create_win(conn, transaction_params) do
    with {:ok, %Transaction{} = transaction} <- Transactions.create_win(transaction_params) do
      conn
      |> render(:create_transaction, transaction: transaction)
    end
  end
end
