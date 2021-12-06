defmodule Partpicker.Library.ConnectorManufacturerData do
  use Ecto.Schema

  schema "connector_manufacturer_data" do
    belongs_to :connector, Partpicker.Library.Connector
    belongs_to :manufacturer_data, Partpicker.Library.ManufacturerData
    timestamps()
  end
end
