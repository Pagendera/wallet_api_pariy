defmodule WalletApiPariyWeb.UserControllerTest do
  use WalletApiPariyWeb.ConnCase
  import WalletApiPariy.Factory

  alias WalletApiPariy.Users 

  @username Application.compile_env(:wallet_api_pariy, :basic_auth)[:username]
  @password Application.compile_env(:wallet_api_pariy, :basic_auth)[:password]

  describe "show_balance/2" do
    test "renders user balance when user exists", %{conn: conn} do
      insert(:user, name: "Alice", balance: 500)

      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/user/balance", %{"user" => "Alice"})

      assert json_response(conn, 200)["user"] == "Alice"
      assert json_response(conn, 200)["balance"] == 500
      assert json_response(conn, 200)["status"] == "RS_OK"
    end

    test "creates user with default balance when user does not exist", %{conn: conn} do
      conn =
        conn
        |> using_basic_auth(@username, @password)
        |> post(~p"/user/balance", %{"user" => "Bob"})

      assert json_response(conn, 200)["user"] == "Bob"
      assert json_response(conn, 200)["balance"] == Users.default_balance()
      assert json_response(conn, 200)["status"] == "RS_OK"
    end
  end


  defp using_basic_auth(conn, username, password) do
    header_content = "Basic " <> Base.encode64("#{username}:#{password}")
    put_req_header(conn, "authorization", header_content)
  end
end
