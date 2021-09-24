defmodule Partpicker.Repo.Migrations.AddPreferredTimezone do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :preferred_timezone, :string
    end
  end
end
