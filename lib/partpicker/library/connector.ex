defmodule Partpicker.Library.Connector do
  use Ecto.Schema
  import Ecto.Changeset

  schema "connectors" do
    field :description, :string

    embeds_many :links, Link do
      field :url, :string
    end

    field :manufacturer, :string
    field :name, :string
    field :pn, :string

    timestamps()
  end

  @doc false
  def changeset(connector, attrs) do
    connector
    |> cast(attrs, [:name, :description, :manufacturer, :pn])
    |> validate_required([:name, :description, :manufacturer, :pn])
    |> cast_embed(:links, required: true, with: &link_changeset/2)
  end

  def link_changeset(link, attrs \\ %{}) do
    link
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
