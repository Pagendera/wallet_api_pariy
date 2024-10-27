defmodule WalletApiPariy.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias WalletApiPariy.Repo
  alias WalletApiPariy.Users.User

  @default_currency "EUR"
  @default_balance 1000

  def get_user_by_name(name) when is_binary(name) do
    Repo.one(from u in User, where: u.name == ^name)
  end

  def get_user_by_name(_name) do
    {:error, "Name must be a string"}
  end

  def get_balance(name) when is_binary(name) do
    case get_user_by_name(name) do
      nil ->
        create_user(%{name: name, currency: @default_currency, balance: @default_balance})
      user ->
        {:ok, user}
    end
  end

  def get_balance(_name) do
    {:error, "Name must be a string"}
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end
end
