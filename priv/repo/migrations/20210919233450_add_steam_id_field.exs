defmodule Partpicker.Repo.Migrations.AddSteamIdField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :steam_id, :string
    end
  end
end
