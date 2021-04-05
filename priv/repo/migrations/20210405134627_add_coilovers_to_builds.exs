defmodule Partpicker.Repo.Migrations.AddCoiloversToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :coilovers, :string
    end
  end
end
