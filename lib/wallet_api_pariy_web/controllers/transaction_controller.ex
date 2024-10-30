defmodule WalletApiPariyWeb.TransactionController do
  use WalletApiPariyWeb, :controller

  alias WalletApiPariy.Transactions
  alias WalletApiPariy.Transactions.Transaction

  action_fallback WalletApiPariyWeb.FallbackController

  def create_bet(conn,
    %{"user" => _name,
    "amount" => _amount,
    "transaction_uuid" => _uuid,
    "currency" =>_currency} = transaction_params
  ) do
    with {:ok, %Transaction{} = transaction} <- Transactions.create_bet(transaction_params) do
      conn
      |> render(:create_transaction, transaction: transaction)
    end
  end

  def create_bet(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid request", status: "RS_UNKNOWN"})
  end

  def create_win(conn,
    %{"user" => _name,
      "amount" => _amount,
      "transaction_uuid" => _uuid,
      "reference_transaction_uuid" => _ref_uuid,
      "currency" =>_currency} = transaction_params
  ) do
    with {:ok, %Transaction{} = transaction} <- Transactions.create_win(transaction_params) do
      conn
      |> render(:create_transaction, transaction: transaction)
    end
  end

  def create_win(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid request", status: "RS_UNKNOWN"})
  end
end
