defmodule Partpicker.List.Selection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "selections" do
    field :title, :string
    field :base, :float
    field :tax, :float
    field :promo, :string
    field :shipping, :float
    field :where, :string
    field :tags, {:array, :string}

    timestamps()
  end

  def changeset(selection, attrs) do
    selection
    |> cast(attrs, [:title, :base, :promo, :shipping, :tax, :where, :tags])
    |> validate_required([:base, :shipping, :where, :tags])
    |> validate_url(:where)
    |> put_title()
  end

  def validate_url(changeset, field, opts \\ [])

  def validate_url(changeset, field, opts) do
    value = get_field(changeset, field)

    if value do
      if error = parse_url(value) do
        add_error(changeset, field, Keyword.get(opts, :message, error))
      else
        changeset
      end
    else
      changeset
    end
  end

  def parse_url(value) do
    case URI.parse(value) do
      %URI{scheme: nil} ->
        "is missing a scheme (e.g. https)"

      %URI{host: nil} ->
        "is missing a host"

      %URI{host: host} ->
        case :inet.gethostbyname(to_charlist(host)) do
          {:ok, _} -> nil
          {:error, _} -> "invalid host"
        end
    end
  end

  def put_title(changeset) do
    if get_change(changeset, :title) do
      changeset
    else
      put_change(changeset, :title, get_field(changeset, :where))
    end
  end
end
