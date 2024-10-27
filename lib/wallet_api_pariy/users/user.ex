defmodule WalletApiPariy.Users.User do
  @moduledoc """
  The User schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :balance, :integer
    field :currency, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :currency, :balance])
    |> validate_required([:name, :currency, :balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> unique_constraint(:name)
  end
end
