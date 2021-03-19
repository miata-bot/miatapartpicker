defmodule Partpicker.Repo.Migrations.AddFeaturedBuilds do
  use Ecto.Migration

  def change do
    create table(:featured_builds) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :build_id, references(:builds, on_delete: :delete_all)
      timestamps()
    end

    create unique_index(:featured_builds, :user_id)
    create unique_index(:featured_builds, :build_)
  end
end
