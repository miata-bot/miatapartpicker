defmodule Partpicker.List.Part do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parts" do
    belongs_to :list, Partpicker.List
    belongs_to :selection, Partpicker.List.Selection
    field :name, :string
    field :paid, :float
    field :discount, :float
    timestamps()
  end

  def changeset(part, attrs) do
    part
    |> cast(attrs, [:name, :paid, :discount])
    |> validate_required([:name])
  end
end
