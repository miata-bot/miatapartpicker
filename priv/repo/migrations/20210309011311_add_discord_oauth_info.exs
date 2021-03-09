defmodule Partpicker.Repo.Migrations.AddDiscordOauthInfo do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :discord_oauth_info, :map
    end
  end
end
