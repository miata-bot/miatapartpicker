defmodule Partpicker.Repo.Migrations.AddUserRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :roles, {:array, :string}, default: []
      remove :admin, :boolean
    end
  end
end
