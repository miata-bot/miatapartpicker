defmodule Partpicker.Repo.Migrations.AddSearchExtensions do
  use Ecto.Migration

  def up do
    # execute "CREATE EXTENSION if not exists pg_trgm"
    # execute "CREATE EXTENSION if not exists fuzzystrmatch"
  end

  def down do
    # execute "DROP EXTENSION fuzzystrmatch"
    # execute "DROP EXTENSION pg_trgm"
  end
end
