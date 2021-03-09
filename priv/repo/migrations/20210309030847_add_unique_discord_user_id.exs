defmodule Partpicker.Repo.Migrations.AddUniqueDiscordUserId do
  use Ecto.Migration

  def change do
    create unique_index(:users, :discord_user_id)
  end
end
