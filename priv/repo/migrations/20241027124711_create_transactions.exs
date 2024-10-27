defmodule WalletApiPariy.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :uuid, :uuid
      add :is_closed, :boolean, default: false, null: false
      add :amount, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:user_id])
    create unique_index(:transactions, [:uuid])
  end
end
