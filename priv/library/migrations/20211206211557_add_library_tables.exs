defmodule Partpicker.Library.Repo.Migrations.AddLibraryTables do
  use Ecto.Migration

  def change do
    create table(:chassis) do
      add :make, :string, null: false
      add :model, :string, null: false
      add :year, :integer, null: false
      timestamps()
    end
    create unique_index(:chassis, [:make, :model, :year])

    create table(:connectors) do
      add :chassis_id, references(:chassis), null: false
      add :name, :string, null: false
      add :description, :string, null: false
      timestamps()
    end

    create unique_index(:connectors, [:chassis_id, :name])

    create table(:purchase_links) do
      add :url, :string, null: false
      timestamps()
    end

    create unique_index(:purchase_links, [:url])

    create table(:connector_purchase_links) do
      add :connector_id, references(:connectors), null: false
      add :purchase_link_id, references(:purchase_links), null: false
      timestamps()
    end

    create unique_index(:connector_purchase_links, [:connector_id, :purchase_link_id])

    create table(:manufacturer_data) do
      add :manufacturer, :string, null: false
      add :part_number, :string, null: false
      timestamps()
    end

    create unique_index(:manufacturer_data, [:manufacturer, :part_number])

    create table(:connector_manufacturer_data) do
      add :connector_id, references(:connectors), null: false
      add :manufacturer_data_id, references(:manufacturer_data), null: false
      timestamps()
    end

    create unique_index(:connector_manufacturer_data, [:connector_id, :manufacturer_data_id])
  end
end
