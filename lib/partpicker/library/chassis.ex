defmodule Partpicker.Library.Chassis do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chassis" do
    field :make, :string
    field :model, :string
    field :year, :integer
    timestamps()
  end

  def changeset(chassis, attrs) do
    chassis
    |> cast(attrs, [:make, :model, :year])
    |> validate_required([:make, :mode, :year])
    |> unique_constraint([:make, :mode, :year])
  end
end
