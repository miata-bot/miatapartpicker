defmodule Partpicker.Repo.Migrations.AddMileageToBuild do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :mileage, :integer
    end
  end
end
