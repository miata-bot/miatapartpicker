defmodule Partpicker.Repo.Migrations.AddUserIdToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      modify(:user_id, :id, null: false)
    end
  end
end
