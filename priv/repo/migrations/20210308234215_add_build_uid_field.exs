defmodule Partpicker.Repo.Migrations.AddBuildUidField do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :uid, :string
    end

    create unique_index(:builds, [:uid])
  end
end
