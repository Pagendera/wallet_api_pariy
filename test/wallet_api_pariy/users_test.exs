defmodule WalletApiPariy.UsersTest do
  use WalletApiPariy.DataCase
  import WalletApiPariy.Factory

  alias WalletApiPariy.Users

  describe "get_user_by_name/1" do
    test "returns user when it exists" do
      user = insert(:user, name: "Alice")
      assert Users.get_user_by_name("Alice") == user
    end

    test "returns nil when user does not exist" do
      assert Users.get_user_by_name("Nonexistent") == nil
    end
  end

  describe "get_balance/1" do
    test "creates user with default balance if not found" do
      assert {:ok, user} = Users.get_balance("Bob")
      assert user.name == "Bob"
      assert user.balance == Users.default_balance()
      assert user.currency == Users.default_currency()
    end

    test "returns existing user balance" do
      insert(:user, name: "Alice", balance: 500)
      assert {:ok, user} = Users.get_balance("Alice")
      assert user.balance == 500
    end
  end

  describe "update_user/2" do
    test "successfully updates a user with valid attributes" do
      user = insert(:user, name: "Alice", balance: 500)

      update_attrs = %{name: "Alice Updated", balance: 600, currency: "USD"}
      assert {:ok, updated_user} = Users.update_user(user, update_attrs)

      assert updated_user.name == "Alice Updated"
      assert updated_user.balance == 600
      assert updated_user.currency == "USD"
    end

    test "fails to update user with invalid attributes" do
      user = insert(:user, name: "Alice", balance: 500)

      invalid_attrs = %{name: "Alice", balance: -100, currency: "USD"}
      assert {:error, changeset} = Users.update_user(user, invalid_attrs)

      refute changeset.valid?
      assert "must be greater than or equal to 0" in errors_on(changeset).balance
    end

    test "fails to update user with non-unique name" do
      insert(:user, name: "Bob")
      user = insert(:user, name: "Alice")

      invalid_attrs = %{name: "Bob", balance: 500, currency: "USD"}
      assert {:error, changeset} = Users.update_user(user, invalid_attrs)

      refute changeset.valid?
      assert "has already been taken" in errors_on(changeset).name
    end
  end
end
