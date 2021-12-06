defmodule Partpicker.Library.Connector do
  use Ecto.Schema
  import Ecto.Changeset
  alias Partpicker.Library.Chassis
  alias Partpicker.Library.ConnectorPurchaseLink
  alias Partpicker.Library.ConnectorManufacturerData

  schema "connectors" do
    belongs_to :chassis, Chassis
    field :name, :string
    field :description, :string
    has_many :connector_purchase_links, ConnectorPurchaseLink
    has_many :purchase_links, through: [:connector_purchase_links, :purchase_link]
    has_one :connector_manufacturer, ConnectorManufacturerData
    has_one :manufacturer_data, through: [:connector_manufacturer, :manufacturer_data]
    timestamps()
  end

  @doc false
  def changeset(connector, attrs) do
    connector
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
    |> unique_constraint([:chassis_id, :name])
  end
end
