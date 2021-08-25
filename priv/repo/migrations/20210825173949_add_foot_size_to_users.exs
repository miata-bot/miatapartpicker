defmodule Partpicker.Repo.Migrations.AddFootSizeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :foot_size, :float
    end
  end
end
