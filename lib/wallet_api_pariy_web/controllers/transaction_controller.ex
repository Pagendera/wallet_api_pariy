defmodule WalletApiPariyWeb.TransactionController do
  use WalletApiPariyWeb, :controller

  alias WalletApiPariy.Transactions
  alias WalletApiPariy.Transactions.Transaction

  action_fallback WalletApiPariyWeb.FallbackController

  def create_bet(conn, transaction_params) do
    with {:ok, %Transaction{} = transaction} <- Transactions.create_bet(transaction_params) do
      conn
      |> put_status(:created)
      |> render(:create_bet, transaction: transaction)
    end
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_transaction(id)

    with {:ok, %Transaction{} = transaction} <- Transactions.update_transaction(transaction, transaction_params) do
      render(conn, :show, transaction: transaction)
    end
  end
end
