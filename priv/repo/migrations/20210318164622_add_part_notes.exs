defmodule Partpicker.Repo.Migrations.AddPartNotes do
  use Ecto.Migration

  def change do
    alter table(:parts) do
      add :notes, :string
    end
  end
end
