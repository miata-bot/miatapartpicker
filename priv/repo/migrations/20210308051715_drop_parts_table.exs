defmodule Partpicker.Repo.Migrations.DropPartsTable do
  use Ecto.Migration

  def change do
    drop table(:parts)
    drop table(:selections)
    drop table(:lists)
  end
end
