defmodule WalletApiPariyWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use WalletApiPariyWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: WalletApiPariyWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: WalletApiPariyWeb.ErrorHTML, json: WalletApiPariyWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, %{message: message, status: status}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: message, status: status})
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: message, status: "RS_ERROR_UNKNOWN"})
  end
end
