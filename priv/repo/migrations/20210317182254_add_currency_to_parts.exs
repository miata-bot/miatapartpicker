defmodule Partpicker.Repo.Migrations.AddCurrencyToParts do
  use Ecto.Migration

  def change do
    alter table(:parts) do
      add :currency, :string, default: "USD"
    end
  end
end
