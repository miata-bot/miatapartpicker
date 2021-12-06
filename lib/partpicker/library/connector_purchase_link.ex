defmodule Partpicker.Library.ConnectorPurchaseLink do
  use Ecto.Schema

  schema "connector_purchase_links" do
    belongs_to :connector, Partpicker.Library.Connector
    belongs_to :purchase_link, Partpicker.Library.PurchaseLink
    timestamps()
  end
end
