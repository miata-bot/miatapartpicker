defmodule Partpicker.TCG.PhysicalCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tcg_physical_cards" do
    belongs_to :printing_plate, Partpicker.TCG.PrintingPlate
    field :uuid, :binary
    timestamps()
  end

  def changeset(physical, attrs) do
    physical
    |> cast(attrs, [:uuid])
    |> validate_required([:uuid])
    |> unique_constraint(:uuid)
  end
end
