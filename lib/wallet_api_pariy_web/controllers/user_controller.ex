defmodule WalletApiPariyWeb.UserController do
  use WalletApiPariyWeb, :controller

  alias WalletApiPariy.Users
  alias WalletApiPariy.Users.User

  action_fallback WalletApiPariyWeb.FallbackController

  def show_balance(conn, %{"user" => name}) do
    with {:ok, %User{} = user} <- Users.get_balance(name) do
      conn
      |> render(:show_balance, user: user)
    end
  end

  def show_balance(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid request", status: "RS_UNKNOWN"})
  end
end
