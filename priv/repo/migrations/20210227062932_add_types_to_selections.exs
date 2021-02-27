defmodule Partpicker.Repo.Migrations.AddTypesToSelections do
  use Ecto.Migration

  def change do
    alter table(:selections) do
      add :tags, {:array, :string}, null: false
    end
  end
end
