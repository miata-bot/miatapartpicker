defmodule Partpicker.Repo.Migrations.CreateConnectors do
  use Ecto.Migration

  def change do
    create table(:connectors) do
      add :name, :string
      add :description, :string
      add :links, {:array, :map}
      add :manufacturer, :string
      add :pn, :string

      timestamps()
    end
  end
end
