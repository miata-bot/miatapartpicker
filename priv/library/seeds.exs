alias Partpicker.Library.{
  Repo,
  Chassis,
  Connector,
  ManufacturerData,
  PurchaseLink,
  ConnectorManufacturerData,
  ConnectorPurchaseLink
}

chassis = %Chassis{make: "Mazda", model: "Miata", year: 1990} |> Repo.insert!()
Partpicker.Library.from_csv(chassis, "lib/partpicker/library/na6.csv")
