defmodule Partpicker.TCG.PrintingPlate do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tcg_printing_plates" do
    belongs_to :build, Partpicker.Builds.Build
    has_many :physical_cards, Partpicker.TCG.PhysicalCard
    has_many :virtual_cards, Partpicker.TCG.VirtualCard
    field :filename, :string, null: false
    timestamps()
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:filename])
    |> validate_required([:filename])
    |> unique_constraint(:filename)
  end
end