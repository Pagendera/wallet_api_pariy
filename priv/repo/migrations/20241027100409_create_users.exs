defmodule WalletApiPariy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :currency, :string
      add :balance, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:name])
  end
end
