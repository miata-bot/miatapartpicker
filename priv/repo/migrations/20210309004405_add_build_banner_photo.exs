defmodule Partpicker.Repo.Migrations.AddBuildBannerPhoto do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :banner_photo_id, :uuid
    end
  end
end
