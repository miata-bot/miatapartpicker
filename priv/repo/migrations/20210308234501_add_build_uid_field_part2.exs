defmodule Partpicker.Repo.Migrations.AddBuildUidFieldPart2 do
  use Ecto.Migration

  def change do
    result = repo().query!("SELECT id FROM builds WHERE uid IS NULL", []).rows

    for [id] <- result do
      <<rand::64>> = :crypto.strong_rand_bytes(8)
      repo().query!("UPDATE builds SET uid=$2 WHERE id=$1", [id, Base62.encode(rand)])
    end

    alter table(:builds) do
      modify :uid, :string, null: false
    end
  end
end
