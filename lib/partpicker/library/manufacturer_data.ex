defmodule Partpicker.Library.ManufacturerData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "manufacturer_data" do
    field :manufacturer, :string
    field :part_number, :string
    timestamps()
  end

  def changeset(manufacturer_data, attrs \\ %{}) do
    manufacturer_data
    |> cast(attrs, [:manufacturer, :part_number])
    |> validate_required([:manufacturer, :part_number])
    |> unique_constraint([:manufacturer, :part_number])
  end
end
