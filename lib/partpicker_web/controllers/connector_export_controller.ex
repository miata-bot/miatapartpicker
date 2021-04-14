defmodule PartpickerWeb.ConnectorExportController do
  use PartpickerWeb, :controller
  alias Partpicker.Library
  alias NimbleCSV.RFC4180, as: CSV

  def export(conn, _params) do
    connectors = Library.list_connectors()
    head = ["name", "description", "manufacturer", "part number", "links"]

    rows =
      Enum.map(connectors, fn connector ->
        links = Enum.map(connector.links, &Map.fetch!(&1, :url))
        [connector.name, connector.description, connector.manufacturer, connector.pn | links]
      end)

    csv = IO.iodata_to_binary(CSV.dump_to_iodata([head | rows]))

    send_download(conn, {:binary, csv},
      filename: "na6-connectors.csv",
      disposition: :attachment,
      charset: "utf-8"
    )
  end
end
