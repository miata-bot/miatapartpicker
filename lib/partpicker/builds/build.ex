defmodule Partpicker.Builds.Build do
  use Ecto.Schema
  import Ecto.Changeset

  schema "builds" do
    field :color, :string
    field :make, :string, default: "Mazda"
    field :model, :string, default: "Miata"
    field :year, :integer
    field :user_id, :id
    has_many :parts, Partpicker.Builds.Part

    timestamps()
  end

  @doc false
  def changeset(build, attrs) do
    build
    |> cast(attrs, [:year, :color])
    |> validate_required([:make, :model, :year, :color])
  end
end
