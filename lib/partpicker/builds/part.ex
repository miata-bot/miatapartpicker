defmodule Partpicker.Builds.Part do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parts" do
    belongs_to :build, Partpicker.Builds.Build
    field :name, :string
    field :link, :string
    field :paid, :float
    field :quantity, :integer
    field :installed_at_timestamp, :date
    field :installed_at_mileage, :integer
    field :purchased_at_timestamp, :date
    field :currency, Ecto.Enum, values: [:USD, :NOK], default: :NOK
    field :notes, :string
    timestamps()
  end

  def changeset(part, attrs) do
    part
    |> cast(attrs, [
      :name,
      :link,
      :paid,
      :quantity,
      :installed_at_timestamp,
      :installed_at_mileage,
      :purchased_at_timestamp,
      :currency,
      :notes
    ])
    |> validate_required([:name])
    |> unique_constraint([:build_id, :name])
  end
end
