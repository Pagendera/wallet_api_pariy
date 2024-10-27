defmodule WalletApiPariy.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias WalletApiPariy.Repo

  alias WalletApiPariy.Users.User
  
  def get_balance(name) do
    case Repo.one(from u in User, where: u.name == ^name) do
      nil ->
        create_user(%{name: name, currency: "EUR", balance: 1000})
      user ->
        {:ok, user}
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
