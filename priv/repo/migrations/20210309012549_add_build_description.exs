defmodule Partpicker.Repo.Migrations.AddBuildDescription do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :description, :string
    end
  end
end
