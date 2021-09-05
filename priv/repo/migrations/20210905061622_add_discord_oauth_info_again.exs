defmodule Partpicker.Repo.Migrations.AddDiscordOauthInfoAgain do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar, :string
      add :username, :string
      add :discriminator, :string
    end

    create unique_index(:users, [:username, :discriminator])
  end
end
