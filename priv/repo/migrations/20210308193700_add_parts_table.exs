defmodule Partpicker.Repo.Migrations.AddPartsTable do
  use Ecto.Migration

  def change do
    drop table(:part_imports)

    create table(:parts) do
      add :build_id, references(:builds), null: false
      add :name, :string, null: false
      add :link, :string
      add :paid, :float
      add :quantity, :integer
      add :installed_at_timestamp, :date
      add :installed_at_mileage, :integer
      timestamps()
    end

    create unique_index(:parts, [:build_id, :name])
  end
end
