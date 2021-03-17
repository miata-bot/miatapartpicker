defmodule Partpicker.Repo.Migrations.AddPreferedUnit do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :prefered_unit, :string, default: "miles"
    end
  end
end
