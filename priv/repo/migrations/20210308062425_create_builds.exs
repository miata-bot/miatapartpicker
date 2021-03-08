defmodule Partpicker.Repo.Migrations.CreateBuilds do
  use Ecto.Migration

  def change do
    create table(:builds) do
      add :make, :string
      add :model, :string
      add :year, :integer
      add :color, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:builds, [:user_id])
  end
end
