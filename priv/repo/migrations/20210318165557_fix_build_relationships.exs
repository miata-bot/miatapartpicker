defmodule Partpicker.Repo.Migrations.FixBuildRelationships do
  use Ecto.Migration
  # thanks Mitch
  # https://github.com/elixir-ecto/ecto/issues/722#issuecomment-663930794

  def change do
    drop constraint("parts", "parts_build_id_fkey")

    alter table(:parts) do
      modify :build_id, references(:builds, on_delete: :delete_all), null: false
    end

    drop constraint("photos", "photos_build_id_fkey")

    alter table(:photos) do
      modify :build_id, references(:builds, on_delete: :delete_all), null: false
    end
  end
end
