defmodule Partpicker.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Partpicker.Library.Repo

  alias Partpicker.Library.Chassis
  alias Partpicker.Library.Connector
  alias Partpicker.Library.ManufacturerData
  alias Partpicker.Library.ConnectorManufacturerData
  alias Partpicker.Library.PurchaseLink
  alias Partpicker.Library.ConnectorPurchaseLink

  alias NimbleCSV.RFC4180, as: CSV

  def list_chassis() do
    Repo.all(Chassis)
  end

  def get_chassis(id) do
    Repo.get!(Chassis, id)
  end

  def from_csv(chassis, path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn [name, description, manufacturer, part_number, purchase_link] ->
      Ecto.Multi.new()
      |> multi_manufacturer_data(manufacturer, part_number)
      |> multi_purchase_link(purchase_link)
      |> Ecto.Multi.insert(:connector, %Connector{
        chassis_id: chassis.id,
        name: name,
        description: description
      })
      |> Ecto.Multi.run(:connector_manufacturer_data, fn repo,
                                                         %{connector: connector} = changes ->
        if manufacturer_data = changes[:manufacturer_data] do
          repo.insert(%ConnectorManufacturerData{
            manufacturer_data_id: manufacturer_data.id,
            connector_id: connector.id
          })
        else
          {:ok, nil}
        end
      end)
      |> Ecto.Multi.run(:connector_purchase_link, fn repo, %{connector: connector} = changes ->
        if purchase_link = changes[:purchase_link] do
          repo.insert(%ConnectorPurchaseLink{
            purchase_link_id: purchase_link.id,
            connector_id: connector.id
          })
        else
          {:ok, nil}
        end
      end)
    end)
    |> Stream.map(fn multi ->
      Repo.transaction(multi)
    end)
  end

  def multi_manufacturer_data(multi, "", "") do
    multi
  end

  def multi_manufacturer_data(multi, manufacturer, part_number) do
    multi
    |> Ecto.Multi.run(:manufacturer_data_lookup, fn repo, _changes ->
      existing =
        repo.one(
          from md in ManufacturerData,
            where: md.manufacturer == ^manufacturer and md.part_number == ^part_number
        )

      {:ok, existing || %ManufacturerData{manufacturer: manufacturer, part_number: part_number}}
    end)
    |> Ecto.Multi.insert_or_update(:manufacturer_data, fn %{
                                                            manufacturer_data_lookup:
                                                              manufacturer_data
                                                          } ->
      change(manufacturer_data, %{manufacturer: manufacturer, part_number: part_number})
    end)
  end

  def multi_purchase_link(multi, "") do
    multi
  end

  def multi_purchase_link(multi, purchase_link_url) do
    multi
    |> Ecto.Multi.run(:purchase_link_lookup, fn repo, _chagnes ->
      existing = repo.one(from pl in PurchaseLink, where: pl.url == ^purchase_link_url)
      {:ok, existing || %PurchaseLink{url: purchase_link_url}}
    end)
    |> Ecto.Multi.insert_or_update(:purchase_link, fn %{purchase_link_lookup: purchase_link} ->
      change(purchase_link, %{url: purchase_link_url})
    end)
  end

  @doc """
  Returns the list of connectors.

  ## Examples

      iex> list_connectors()
      [%Connector{}, ...]

  """
  def list_connectors do
    Repo.all(from c in Connector, order_by: {:asc, :name})
    |> Repo.preload([:manufacturer_data, :purchase_links])
  end

  @doc """
  Gets a single connector.

  Raises `Ecto.NoResultsError` if the Connector does not exist.

  ## Examples

      iex> get_connector!(123)
      %Connector{}

      iex> get_connector!(456)
      ** (Ecto.NoResultsError)

  """
  def get_connector!(id),
    do:
      Repo.get!(Connector, id)
      |> Repo.preload([:manufacturer_data, :purchase_links])

  @doc """
  Creates a connector.

  ## Examples

      iex> create_connector(%{field: value})
      {:ok, %Connector{}}

      iex> create_connector(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_connector(attrs \\ %{}) do
    %Connector{}
    |> Connector.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a connector.

  ## Examples

      iex> update_connector(connector, %{field: new_value})
      {:ok, %Connector{}}

      iex> update_connector(connector, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_connector(%Connector{} = connector, attrs) do
    connector
    |> Connector.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a connector.

  ## Examples

      iex> delete_connector(connector)
      {:ok, %Connector{}}

      iex> delete_connector(connector)
      {:error, %Ecto.Changeset{}}

  """
  def delete_connector(%Connector{} = connector) do
    Repo.delete(connector)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking connector changes.

  ## Examples

      iex> change_connector(connector)
      %Ecto.Changeset{data: %Connector{}}

  """
  def change_connector(%Connector{} = connector, attrs \\ %{}) do
    Connector.changeset(connector, attrs)
  end
end
