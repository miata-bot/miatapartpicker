defmodule Partpicker.Repo.Migrations.AddApiTokens do
  use Ecto.Migration

  def change do
    create table(:api_tokens) do
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create unique_index(:api_tokens, [:context, :token])
  end
end
