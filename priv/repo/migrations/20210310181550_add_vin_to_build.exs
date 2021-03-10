defmodule Partpicker.Repo.Migrations.AddVinToBuild do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :vin, :string
    end
  end
end
