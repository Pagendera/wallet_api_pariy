defmodule WalletApiPariy.TransactionsTest do
  use WalletApiPariy.DataCase
  import WalletApiPariy.Factory

  alias WalletApiPariy.Transactions

  describe "create_transaction/1" do
    test "successfully creates a transaction" do
      user = insert(:user, name: "Alice", balance: 500)
      attrs = %{"uuid" => Ecto.UUID.generate(), "amount" => 100, "user_id" => user.id}

      assert {:ok, transaction} = Transactions.create_transaction(attrs)
      assert transaction.amount == 100
      assert transaction.user_id == user.id
      assert transaction.uuid == attrs["uuid"]
    end

    test "fails to create a transaction with invalid attributes" do
      assert {:error, changeset} = Transactions.create_transaction(%{})
      assert changeset.errors[:amount] != nil
      assert changeset.errors[:uuid] != nil
    end
  end

  describe "create_bet/1" do
    test "successfully creates a bet" do
      user = insert(:user, name: "Alice", balance: 500)
      uuid = Ecto.UUID.generate()
      attrs = %{"user" => user.name, "amount" => 100, "transaction_uuid" => uuid}

      assert {:ok, transaction} = Transactions.create_bet(attrs)
      assert transaction.amount == 100
      assert transaction.user_id == user.id
      assert transaction.user.balance == 400
    end

    test "fails to create a bet with insufficient balance" do
      user = insert(:user, name: "Alice", balance: 50)
      uuid = Ecto.UUID.generate()
      attrs = %{"user" => user.name, "amount" => 100, "transaction_uuid" => uuid}

      assert {:error, %{message: "Insufficient balance", status: "RS_ERROR_NOT_ENOUGH_MONEY"}} = Transactions.create_bet(attrs)
    end

    test "fails to create a bet for a non-existent user" do
      uuid = Ecto.UUID.generate()
      attrs = %{"user" => "NonExistentUser", "amount" => 100, "transaction_uuid" => uuid}

      assert {:error, %{message: "User not found", status: "RS_ERROR_USER_DISABLED"}} = Transactions.create_bet(attrs)
    end
  end

  describe "create_win/1" do
    test "successfully creates a win" do
      user = insert(:user, name: "Alice", balance: 400)
      bet_uuid = Ecto.UUID.generate()
      transaction_uuid = Ecto.UUID.generate()

      Transactions.create_bet(%{"user" => user.name, "amount" => 100, "transaction_uuid" => bet_uuid})

      attrs = %{"user" => user.name, "amount" => 150, "transaction_uuid" => transaction_uuid, "reference_transaction_uuid" => bet_uuid}
      assert {:ok, transaction} = Transactions.create_win(attrs)

      assert transaction.amount == 150
      assert transaction.user.balance == 450
    end

    test "fails to create a win with closed reference transaction" do
      user = insert(:user, name: "Alice", balance: 400)
      closed_uuid = Ecto.UUID.generate()
      transaction_uuid = Ecto.UUID.generate()

      Transactions.create_bet(%{"user" => user.name, "amount" => 100, "transaction_uuid" => closed_uuid, "is_closed" => true})

      attrs = %{"user" => user.name, "amount" => 150, "transaction_uuid" => transaction_uuid, "reference_transaction_uuid" => closed_uuid}

      assert {:error, %{message: "Reference transaction is closed", status: "RS_ERROR_DUPLICATE_TRANSACTION"}} = Transactions.create_win(attrs)
    end

    test "fails to create a win for a non-existent user" do
      uuid = Ecto.UUID.generate()
      attrs = %{"user" => "NonExistentUser", "amount" => 100, "transaction_uuid" => uuid, "reference_transaction_uuid" => uuid}

      assert {:error, %{message: "Reference transaction not found", status: "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"}} = Transactions.create_win(attrs)
    end
  end
end
