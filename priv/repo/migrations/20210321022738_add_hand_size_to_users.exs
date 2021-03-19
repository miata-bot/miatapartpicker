defmodule Partpicker.Repo.Migrations.AddHandSizeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hand_size, :float
    end
  end
end
