defmodule Partpicker.Builds.Build do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Partpicker.Builds.Build
  @km_per_mile 1.609344

  schema "builds" do
    belongs_to :user, Partpicker.Accounts.User
    field :uid, :string
    field :color, :string
    field :make, :string, default: "Mazda"
    field :model, :string, default: "Miata"
    field :wheels, :string
    field :tires, :string
    field :year, :integer
    field :description, :string
    field :vin, :string
    field :mileage, :integer
    has_many :parts, Partpicker.Builds.Part
    has_many :photos, Partpicker.Builds.Photo
    field :banner_photo_id, :binary_id
    field :spent_to_date, :float, virtual: true
    timestamps()
  end

  @doc false
  def changeset(build, attrs) do
    build
    |> cast(attrs, [
      :year,
      :color,
      :description,
      :wheels,
      :tires,
      :banner_photo_id,
      :vin
    ])
    |> validate_mileage(attrs[:mileage] || attrs["mileage"])
    |> validate_required([:make, :model])
    |> generate_uid()
  end

  def validate_mileage(changeset, nil) do
    changeset
  end

  def validate_mileage(changeset, mileage) do
    case normalize_mileage(mileage) do
      {:ok, mileage} -> Ecto.Changeset.put_change(changeset, :mileage, mileage)
      {:error, reason} -> Ecto.Changeset.add_error(changeset, :mileage, reason)
    end
  end

  def normalize_mileage(mileage) when is_binary(mileage) do
    case String.split(mileage, "km", parts: 2) do
      [km, ""] ->
        normalize_km(km)

      [mileage] ->
        normalize_miles(mileage)

      _ ->
        {:error, "could not decode mileage"}
    end
  end

  def normalize_mileage(mileage) when is_number(mileage) do
    {:ok, mileage}
  end

  def normalize_km(km) do
    km =
      km
      |> String.trim()
      |> String.replace(",", "")
      |> String.replace("k", "000")
      |> Integer.parse()

    case km do
      {km, ""} -> {:ok, round(km / @km_per_mile)}
      {_, _extra} -> {:error, "is invalid"}
    end
  end

  def normalize_miles(mileage) do
    mileage =
      mileage
      |> String.trim()
      |> String.replace(",", "")
      |> String.replace("k", "000")
      |> Integer.parse()

    case mileage do
      {mileage, ""} -> {:ok, mileage}
      {_, _extra} -> {:error, "is invalid"}
    end
  end

  def calculate_spent_to_date(build) do
    spent_to_date =
      Partpicker.Repo.one(
        from p in Partpicker.Builds.Part, where: p.build_id == ^build.id, select: sum(p.paid)
      )

    %Build{build | spent_to_date: spent_to_date}
  end

  def calculate_mileage(%Build{mileage: nil} = build) do
    build
  end

  def calculate_mileage(%Build{user: %Ecto.Association.NotLoaded{}} = build) do
    Partpicker.Repo.preload(build, [:user])
    |> calculate_mileage()
  end

  def calculate_mileage(%Build{user: %Partpicker.Accounts.User{prefered_unit: :miles}} = build) do
    build
  end

  def calculate_mileage(
        %Build{user: %Partpicker.Accounts.User{prefered_unit: :km}, mileage: mileage} = build
      )
      when is_number(mileage) do
    %Build{build | mileage: round(mileage * @km_per_mile)}
  end

  def generate_uid(%{valid?: false} = changeset), do: changeset

  def generate_uid(changeset) do
    if get_field(changeset, :uid) do
      changeset
    else
      <<rand::64>> = :crypto.strong_rand_bytes(8)
      put_change(changeset, :uid, Base62.encode(rand))
    end
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
