defmodule Partpicker.Repo.Migrations.AddRideHeightToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :ride_height, :float
    end
  end
end
