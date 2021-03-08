defmodule Partpicker.Repo.Migrations.AddOauthIntegrations do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :discord_user_id, :binary
    end
  end
end
