defmodule WalletApiPariyWeb.TransactionControllerTest do
  use WalletApiPariyWeb.ConnCase
  import WalletApiPariy.Factory

  @username Application.compile_env(:wallet_api_pariy, :basic_auth)[:username]
  @password Application.compile_env(:wallet_api_pariy, :basic_auth)[:password]

  describe "create_bet/2" do
    setup do
      user = insert(:user, name: "Alice", balance: 500)
      %{user: user}
    end

    test "creates a bet and renders the transaction", %{conn: conn, user: user} do
      transaction_params = %{
        "user" => user.name,
        "amount" => 200,
        "transaction_uuid" => Ecto.UUID.generate(),
        "currency" => "EUR"
      }

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/transaction/bet", transaction_params)

      assert json_response(conn, 200)["status"] == "RS_OK"
      assert %WalletApiPariy.Transactions.Transaction{amount: 200} =
        WalletApiPariy.Transactions.get_transaction_by_uuid(transaction_params["transaction_uuid"])
    end

    test "returns an error when user not found", %{conn: conn} do
      transaction_params = %{
        "user" => "Unknown User",
        "amount" => 200,
        "transaction_uuid" => Ecto.UUID.generate(),
        "currency" => "EUR"
      }

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/transaction/bet", transaction_params)

      assert json_response(conn, 422)["error"] == "User not found"
      assert json_response(conn, 422)["status"] == "RS_ERROR_USER_DISABLED"
    end

    test "returns an error when insufficient balance", %{conn: conn, user: user} do
      transaction_params = %{
        "user" => user.name,
        "amount" => 600,
        "transaction_uuid" => Ecto.UUID.generate(),
        "currency" => "EUR"
      }

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/transaction/bet", transaction_params)

      assert json_response(conn, 422)["error"] == "Insufficient balance"
      assert json_response(conn, 422)["status"] == "RS_ERROR_NOT_ENOUGH_MONEY"
    end
  end

  describe "create_win/2" do
    setup do
      user = insert(:user, name: "Alice", balance: 500)
      transaction_params = %{
        "user" => user.name,
        "amount" => 100,
        "transaction_uuid" => Ecto.UUID.generate()
      }
      {:ok, bet_transaction} = WalletApiPariy.Transactions.create_bet(transaction_params)
      %{user: user, bet_transaction: bet_transaction}
    end

    test "creates a win and renders the transaction", %{conn: conn, user: user, bet_transaction: bet_transaction} do
      win_params = %{
        "user" => user.name,
        "amount" => 150,
        "transaction_uuid" => Ecto.UUID.generate(),
        "reference_transaction_uuid" => bet_transaction.uuid,
        "currency" => "EUR"
      }

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/transaction/win", win_params)

      assert json_response(conn, 200)["status"] == "RS_OK"
      assert WalletApiPariy.Transactions.get_transaction_by_uuid(win_params["transaction_uuid"])
    end

    test "returns an error when reference transaction not found", %{conn: conn} do
      win_params = %{
        "user" => "Alice",
        "amount" => 150,
        "transaction_uuid" => Ecto.UUID.generate(),
        "reference_transaction_uuid" => Ecto.UUID.generate(),
        "currency" => "EUR"
      }

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/transaction/win", win_params)

      assert json_response(conn, 422)["error"] == "Reference transaction not found"
      assert json_response(conn, 422)["status"] == "RS_ERROR_TRANSACTION_DOES_NOT_EXIST"
    end

    test "returns an error when reference transaction is closed", %{conn: conn, bet_transaction: bet_transaction} do
      WalletApiPariy.Transactions.update_transaction(bet_transaction, %{"is_closed" => true})

      win_params = %{
        "user" => "Alice",
        "amount" => 150,
        "transaction_uuid" => Ecto.UUID.generate(),
        "reference_transaction_uuid" => bet_transaction.uuid,
        "currency" => "EUR"
      }

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/transaction/win", win_params)

      assert json_response(conn, 422)["error"] == "Reference transaction is closed"
      assert json_response(conn, 422)["status"] == "RS_ERROR_DUPLICATE_TRANSACTION"
    end
  end

  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    put_req_header(conn, "authorization", header_content)
  end
end
