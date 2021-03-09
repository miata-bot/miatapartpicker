defmodule Partpicker.Repo.Migrations.AllowNullCarinfo do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      modify :color, :string, null: true
      modify :year, :integer, null: true
    end
  end
end
