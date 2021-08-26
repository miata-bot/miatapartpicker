defmodule Partpicker.Repo.Migrations.AddTcgTables do
  use Ecto.Migration

  def change do
    create table(:tcg_printing_plates) do
      add :build_id, references(:builds)
      add :filename, :string, null: false
      timestamps()
    end

    create unique_index(:tcg_printing_plates, [:id, :filename])

    create table(:tcg_physical_cards) do
      add :printing_plate_id, references(:tcg_printing_plates), null: false
      add :uuid, :binary, null: false
      timestamps()
    end

    create unique_index(:tcg_physical_cards, [:uuid])
    create index(:tcg_physical_cards, [:id, :printing_plate_id])

    create table(:tcg_virtual_cards) do
      add :printing_plate_id, references(:tcg_printing_plates), null: false
      add :user_id, references(:users), null: false
      add :uuid, :binary, null: false
      timestamps()
    end

    create unique_index(:tcg_virtual_cards, [:uuid])
    create index(:tcg_virtual_cards, [:id, :printing_plate_id])

    create table(:tcg_trade_requests) do
      add :offer_id, references(:tcg_virtual_cards), null: false
      add :trade_id, references(:tcg_virtual_cards), null: false
      add :sender_id, references(:users), null: false
      add :receiver_id, references(:users), null: false
      add :status, :string
      timestamps()
    end
  end
end
