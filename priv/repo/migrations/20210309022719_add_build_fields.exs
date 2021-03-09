defmodule Partpicker.Repo.Migrations.AddBuildFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :instagram_handle, :string
    end

    alter table(:builds) do
      add :wheels, :string
      add :tires, :string
    end
  end
end
