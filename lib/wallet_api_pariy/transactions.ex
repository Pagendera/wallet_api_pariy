defmodule WalletApiPariy.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias WalletApiPariy.Repo

  alias WalletApiPariy.Transactions.Transaction
  alias WalletApiPariy.Users

  def get_transaction(id), do: Repo.get(Transaction, id)

  def get_transaction_by_uuid(uuid) do
    Repo.get_by(Transaction, uuid: uuid)
  end

  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  def create_bet(%{"user" => name, "amount" => amount, "transaction_uuid" => uuid} = attrs \\ %{}) do
    with user when not is_nil(user) <- Users.get_user_by_name(name),
         true <- user.balance >= amount do

      Repo.transaction(fn ->
        Users.update_user(user, %{balance: user.balance - amount})

        transaction_attrs =
          Map.merge(attrs, %{"user_id" => user.id, "uuid" => uuid})

        case create_transaction(transaction_attrs) do
          {:ok, transaction} ->
            Repo.preload(transaction, :user)

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)

    else
      nil -> {:error, %{message: "User not found", status: "RS_ERROR_USER_DISABLED"}}
      false -> {:error, %{message: "Insufficient balance", status: "RS_ERROR_NOT_ENOUGH_MONEY"}}
    end
  end

  def create_win(
    %{"user" => name, "amount" => amount, "transaction_uuid" => uuid, "reference_transaction_uuid" => ref_uuid} = attrs \\ %{}
  ) do
    with user when not is_nil(user) <- Users.get_user_by_name(name),
         ref_transaction when not is_nil(ref_transaction) <- get_transaction_by_uuid(ref_uuid),
         false <- ref_transaction.is_closed,
         true <- ref_transaction.user_id == user.id do

      Repo.transaction(fn ->
        Users.update_user(user, %{balance: user.balance + amount})
        update_transaction(ref_transaction, %{"is_closed" => true})

        transaction_attrs =
          Map.merge(attrs, %{"user_id" => user.id, "uuid" => uuid, "is_closed" => true})

        case create_transaction(transaction_attrs) do
          {:ok, transaction} ->
            Repo.preload(transaction, :user)

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)

    else
      nil -> {:error, %{message: "Reference transaction not found", status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}}
      true -> {:error, %{message: "Reference transaction is closed", status: "RS_ERROR_DUPLICATE_TRANSACTION"}}
      _ -> {:error, %{message: "User does not match the reference transaction", status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}}
    end
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
