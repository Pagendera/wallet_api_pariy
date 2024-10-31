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

  def create_bet(attrs \\ %{}) do
    with {:ok, name} <- validate_name(attrs),
         {:ok, user} <- get_user(name),
         {:ok, amount} <- validate_amount(attrs),
         :ok <- validate_balance(user, amount),
         {:ok, uuid} <- validate_uuid(attrs, "transaction_uuid") do
      perform_bet_transaction(user, amount, uuid, attrs)
    else
      {:error, _} = error -> error
    end
  end

  def create_win(attrs \\ %{}) do
    with {:ok, name} <- validate_name(attrs),
         {:ok, user} <- get_user(name),
         {:ok, amount} <- validate_amount(attrs),
         {:ok, uuid} <- validate_uuid(attrs, "transaction_uuid"),
         {:ok, ref_uuid} <- validate_uuid(attrs, "reference_transaction_uuid"),
         {:ok, ref_transaction} <- validate_reference_transaction(ref_uuid, user) do
      perform_win_transaction(user, amount, uuid, ref_transaction, attrs)
    else
      {:error, _} = error -> error
    end
  end

  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  defp validate_balance(user, amount) do
    if user.balance >= amount do
      :ok
    else
      {:error, %{message: "Insufficient balance", status: "RS_ERROR_NOT_ENOUGH_MONEY"}}
    end
  end

  defp perform_bet_transaction(user, amount, uuid, attrs) do
    Repo.transaction(fn ->
      Users.update_user(user, %{balance: user.balance - amount})

      transaction_attrs =
        attrs
        |> Map.merge(%{
          "user_id" => user.id,
          "uuid" => uuid
        })

      case create_transaction(transaction_attrs) do
        {:ok, transaction} ->
          Repo.preload(transaction, :user)
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp perform_win_transaction(user, amount, uuid, ref_transaction, attrs) do
    Repo.transaction(fn ->
      Users.update_user(user, %{balance: user.balance + amount})

      update_transaction(ref_transaction, %{"is_closed" => true})

      transaction_attrs =
        attrs
        |> Map.merge(%{
          "user_id" => user.id,
          "uuid" => uuid,
          "is_closed" => true
        })

      case create_transaction(transaction_attrs) do
        {:ok, transaction} ->
          Repo.preload(transaction, :user)
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp validate_name(%{"user" => name}) when is_binary(name), do: {:ok, name}
  defp validate_name(_), do: {:error, %{message: "Name must be a string", status: "RS_ERROR_WRONG_TYPES"}}

  defp get_user(name) do
    case Users.get_user_by_name(name) do
      nil -> {:error, %{message: "User not found", status: "RS_ERROR_USER_DISABLED"}}
      user -> {:ok, user}
    end
  end

  defp validate_amount(%{"amount" => amount}) when is_number(amount), do: {:ok, amount}
  defp validate_amount(_), do: {:error, %{message: "Invalid amount", status: "RS_ERROR_WRONG_TYPES"}}

  defp validate_uuid(attrs, key) do
    case Map.get(attrs, key) do
      uuid when is_binary(uuid) -> {:ok, uuid}
      _ -> {:error, %{message: "Invalid #{key}", status: "RS_ERROR_WRONG_TYPES"}}
    end
  end

  defp validate_reference_transaction(ref_uuid, user) do
    case get_transaction_by_uuid(ref_uuid) do
      nil ->
        {:error, %{message: "Reference transaction not found", status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}}
      ref_transaction when ref_transaction.is_closed ->
        {:error, %{message: "Reference transaction is closed", status: "RS_ERROR_DUPLICATE_TRANSACTION"}}
      ref_transaction when ref_transaction.user_id != user.id ->
        {:error, %{message: "User does not match the reference transaction", status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}}
      ref_transaction ->
        {:ok, ref_transaction}
    end
  end
end
