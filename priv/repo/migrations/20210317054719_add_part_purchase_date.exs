defmodule Partpicker.Repo.Migrations.AddPartPurchaseDate do
  use Ecto.Migration

  def change do
    alter table(:parts) do
      add :purchased_at_timestamp, :date
    end
  end
end
