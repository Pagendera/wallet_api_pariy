defmodule WalletApiPariyWeb.UserControllerTest do
  use WalletApiPariyWeb.ConnCase

  alias WalletApiPariy.Users.User

  @create_attrs %{
    user: "some user",
    balance: "1200",
    currency: "some currency"
  }
  @invalid_attrs %{user: nil, balance: nil, currency: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/users/#{id}")

      assert %{
               "id" => ^id,
               "balance" => "120.5",
               "currency" => "some currency",
               "user" => "some user"
             } = json_response(conn, 200)["data"]
    end
  end
end
