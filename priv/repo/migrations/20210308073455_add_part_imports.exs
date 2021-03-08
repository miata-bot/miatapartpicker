defmodule Partpicker.Repo.Migrations.AddPartImports do
  use Ecto.Migration

  def change do
    create table(:part_imports, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :build_id, references(:builds), null: false
      add :completed_at_timestamp, :utc_datetime
      add :errors, {:array, :map}
      timestamps()
    end
  end
end
