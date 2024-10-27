defmodule WalletApiPariy.Transactions.Transaction do
  @moduledoc """
  The Transaction schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :uuid, Ecto.UUID
    field :is_closed, :boolean, default: false
    field :amount, :integer
    belongs_to :user, WalletApiPariy.Users.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:uuid, :is_closed, :amount, :user_id])
    |> validate_required([:uuid, :is_closed, :amount, :user_id])
    |> validate_number(:amount, greater_than: 0)
    |> unique_constraint(:uuid)
  end
end
