defmodule Partpicker.LibraryTest do
  use Partpicker.DataCase

  alias Partpicker.Library

  describe "connectors" do
    alias Partpicker.Library.Connector

    @valid_attrs %{
      description: "some description",
      links: [],
      manufacturer: "some manufacturer",
      name: "some name",
      pn: "some pn"
    }
    @update_attrs %{
      description: "some updated description",
      links: [],
      manufacturer: "some updated manufacturer",
      name: "some updated name",
      pn: "some updated pn"
    }
    @invalid_attrs %{description: nil, links: nil, manufacturer: nil, name: nil, pn: nil}

    def connector_fixture(attrs \\ %{}) do
      {:ok, connector} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Library.create_connector()

      connector
    end

    test "list_connectors/0 returns all connectors" do
      connector = connector_fixture()
      assert Library.list_connectors() == [connector]
    end

    test "get_connector!/1 returns the connector with given id" do
      connector = connector_fixture()
      assert Library.get_connector!(connector.id) == connector
    end

    test "create_connector/1 with valid data creates a connector" do
      assert {:ok, %Connector{} = connector} = Library.create_connector(@valid_attrs)
      assert connector.description == "some description"
      assert connector.links == []
      assert connector.manufacturer == "some manufacturer"
      assert connector.name == "some name"
      assert connector.pn == "some pn"
    end

    test "create_connector/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Library.create_connector(@invalid_attrs)
    end

    test "update_connector/2 with valid data updates the connector" do
      connector = connector_fixture()
      assert {:ok, %Connector{} = connector} = Library.update_connector(connector, @update_attrs)
      assert connector.description == "some updated description"
      assert connector.links == []
      assert connector.manufacturer == "some updated manufacturer"
      assert connector.name == "some updated name"
      assert connector.pn == "some updated pn"
    end

    test "update_connector/2 with invalid data returns error changeset" do
      connector = connector_fixture()
      assert {:error, %Ecto.Changeset{}} = Library.update_connector(connector, @invalid_attrs)
      assert connector == Library.get_connector!(connector.id)
    end

    test "delete_connector/1 deletes the connector" do
      connector = connector_fixture()
      assert {:ok, %Connector{}} = Library.delete_connector(connector)
      assert_raise Ecto.NoResultsError, fn -> Library.get_connector!(connector.id) end
    end

    test "change_connector/1 returns a connector changeset" do
      connector = connector_fixture()
      assert %Ecto.Changeset{} = Library.change_connector(connector)
    end
  end
end
