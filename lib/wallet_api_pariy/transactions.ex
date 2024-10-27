defmodule WalletApiPariy.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias WalletApiPariy.Repo

  alias WalletApiPariy.Transactions.Transaction
  alias WalletApiPariy.Users

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction(id), do: Repo.get(Transaction, id)

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
      nil -> {:error, "User not found"}
      false -> {:error, "Insufficient balance"}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end
end
