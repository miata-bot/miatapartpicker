defmodule Partpicker.Builds.Part do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parts" do
    field :name, :string
    field :paid, :float
    field :quantity, :integer
    field :installed_at_timestamp, :utc_datetime
    field :installed_at_mileage, :integer
    timestamps()
  end

  def changeset(part, attrs) do
    part
    |> cast(attrs, [:name, :paid, :quantity, :installed_at_timestamp, :installed_at_mileage])
    |> validate_required([:name])
  end
end
