defmodule Partpicker.Repo.Migrations.AddPhotosTable do
  use Ecto.Migration

  def change do
    create table(:photos, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :build_id, references(:builds), null: false
      add :path, :string, null: false
      add :mime, :string
      add :filename, :string
      timestamps()
    end

    create unique_index(:photos, [:id, :path])
  end
end
