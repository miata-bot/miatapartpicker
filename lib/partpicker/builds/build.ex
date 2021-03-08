defmodule Partpicker.Builds.Build do
  use Ecto.Schema
  import Ecto.Changeset

  schema "builds" do
    belongs_to :user, Partpicker.Accounts.User
    field :color, :string
    field :make, :string, default: "Mazda"
    field :model, :string, default: "Miata"
    field :year, :integer
    has_many :parts, Partpicker.Builds.Part
    has_many :photos, Partpicker.Builds.Photo

    timestamps()
  end

  @doc false
  def changeset(build, attrs) do
    build
    |> cast(attrs, [:year, :color])
    |> validate_required([:make, :model, :year, :color])
  end

  def color_by_id(build, id) do
    Enum.find(colors_for(build), fn
      %{id: ^id} -> true
      _ -> false
    end)
  end

  def colors_for(%{year: _year} = _build),
    do: [
      %{id: "0", name: "Other", color: "bg-gray-100"},
      %{id: "1", name: "Mariner Blue", color: "bg-blue-500"},
      %{id: "2", name: "Laguna Blue", color: "bg-blue-500"},
      %{id: "3", name: "Montego Blue", color: "bg-blue-500"},
      %{id: "4", name: "Starlight Blue Mica", color: "bg-blue-500"},
      %{id: "5", name: "Twilight Blue", color: "bg-blue-500"},
      %{id: "6", name: "Sapphire Blue Mica", color: "bg-blue-500"},
      %{id: "7", name: "Midnight Blue Mica", color: "bg-blue-500"},
      %{id: "8", name: "Crystal Blue Metallic", color: "bg-blue-500"},
      %{id: "9", name: "Laser Blue Mica", color: "bg-blue-500"},
      %{id: "10", name: "Strato Blue", color: "bg-blue-500"},
      %{id: "11", name: "Razor Blue Metallic", color: "bg-blue-500"},
      %{id: "13", name: "Winning Blue", color: "bg-blue-500"},
      %{id: "14", name: "Stormy Blue Metallic", color: "bg-blue-500"},
      %{id: "15", name: "Icy Blue Metallic", color: "bg-blue-500"},
      %{id: "16", name: "Nereus Blue", color: "bg-blue-500"},
      %{id: "17", name: "Classic Red", color: "bg-red-500"},
      %{id: "18", name: "Mica Merlot", color: "bg-red-800"},
      %{id: "19", name: "Mahogany Mica", color: "bg-pink-900"},
      %{id: "20", name: "Garnet Red", color: "bg-red-700"},
      %{id: "21", name: "Velocity Red", color: "bg-red-500"},
      %{id: "22", name: "Black Cherry Mica", color: "bg-red-500"},
      %{id: "23", name: "True Red", color: "bg-red-500"},
      %{id: "24", name: "Copper Red", color: "bg-red-500"},
      %{id: "25", name: "Soul Red", color: "bg-red-500"},
      %{id: "26", name: "Zeal Red", color: "bg-red-500"},
      %{id: "27", name: "Silver Stone Metallic", color: "bg-gray-200"},
      %{id: "28", name: "Highlight Silver Metallic", color: "bg-gray-200"},
      %{id: "29", name: "Sunlight Silver Metallic", color: "bg-gray-200"},
      %{id: "30", name: "Titanium Grey Metallic", color: "bg-gray-200"},
      %{id: "31", name: "Galaxy Grey", color: "bg-gray-200"},
      %{id: "32", name: "Liquid Silver Metallic", color: "bg-gray-200"},
      %{id: "33", name: "Metropolitan Grey Mica", color: "bg-gray-200"},
      %{id: "34", name: "Dolphin Grey Mica", color: "bg-gray-200"},
      %{id: "35", name: "Meteor Grey", color: "bg-gray-200"},
      %{id: "36", name: "Crystal White", color: "bg-gray-100"},
      %{id: "37", name: "Chaste White", color: "bg-gray-100"},
      %{id: "38", name: "Pure White", color: "bg-gray-100"},
      %{id: "39", name: "Marble White", color: "bg-gray-100"},
      %{id: "40", name: "Crystal White Pearl", color: "bg-gray-100"},
      %{id: "41", name: "Sunburst Yellow", color: "bg-yellow-500"},
      %{id: "42", name: "Blazing Yellow Mica", color: "bg-yellow-500"},
      %{id: "43", name: "Vivid Yellow", color: "bg-yellow-500"},
      %{id: "44", name: "Competition Yellow", color: "bg-yellow-500"},
      %{id: "52", name: "Evolution Orange", color: "bg-yellow-500"},
      %{id: "53", name: "Lava Orange", color: "bg-yellow-500"},
      %{id: "45", name: "British Racing Green", color: "bg-green-500"},
      %{id: "46", name: "Marina Green", color: "bg-green-500"},
      %{id: "47", name: "Emerald Mica", color: "bg-green-500"},
      %{id: "48", name: "Splash Green", color: "bg-green-500"},
      %{id: "49", name: "Nordic Green Mica", color: "bg-green-500"},
      %{id: "50", name: "Highland Green", color: "bg-green-500"},
      %{id: "51", name: "Brilliant Black", color: "bg-gray-900"},
      %{id: "54", name: "Black Mica", color: "bg-gray-900"},
      %{id: "55", name: "Sparkling Black Mica", color: "bg-gray-900"},
      %{id: "56", name: "Jet Black", color: "bg-gray-900"}
    ]
end
