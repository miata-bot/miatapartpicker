defmodule Partpicker.Repo.Migrations.CreatePartsTable do
  use Ecto.Migration

  def change do
    create table(:lists) do
      add :user_id, references(:users), null: false
      add :tag, :string, null: false
      timestamps()
    end

    create table(:selections) do
      add :title, :string, null: false
      add :base, :float, null: false
      add :promo, :string
      add :tax, :float
      add :shipping, :float, null: false
      add :where, :string, null: false
      timestamps()
    end

    create table(:parts) do
      add :list_id, references(:lists), null: false
      add :selection_id, references(:selections)
      add :name, :string, null: false
      add :discount, :float
      add :paid, :float
      timestamps()
    end
  end
end
