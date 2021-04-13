defmodule PartpickerWeb.ConnectorLiveTest do
  use PartpickerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Partpicker.Library

  @create_attrs %{
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

  defp fixture(:connector) do
    {:ok, connector} = Library.create_connector(@create_attrs)
    connector
  end

  defp create_connector(_) do
    connector = fixture(:connector)
    %{connector: connector}
  end

  describe "Index" do
    setup [:create_connector]

    test "lists all connectors", %{conn: conn, connector: connector} do
      {:ok, _index_live, html} = live(conn, Routes.connector_index_path(conn, :index))

      assert html =~ "Listing Connectors"
      assert html =~ connector.description
    end

    test "saves new connector", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.connector_index_path(conn, :index))

      assert index_live |> element("a", "New Connector") |> render_click() =~
               "New Connector"

      assert_patch(index_live, Routes.connector_index_path(conn, :new))

      assert index_live
             |> form("#connector-form", connector: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#connector-form", connector: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.connector_index_path(conn, :index))

      assert html =~ "Connector created successfully"
      assert html =~ "some description"
    end

    test "updates connector in listing", %{conn: conn, connector: connector} do
      {:ok, index_live, _html} = live(conn, Routes.connector_index_path(conn, :index))

      assert index_live |> element("#connector-#{connector.id} a", "Edit") |> render_click() =~
               "Edit Connector"

      assert_patch(index_live, Routes.connector_index_path(conn, :edit, connector))

      assert index_live
             |> form("#connector-form", connector: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#connector-form", connector: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.connector_index_path(conn, :index))

      assert html =~ "Connector updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes connector in listing", %{conn: conn, connector: connector} do
      {:ok, index_live, _html} = live(conn, Routes.connector_index_path(conn, :index))

      assert index_live |> element("#connector-#{connector.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#connector-#{connector.id}")
    end
  end

  describe "Show" do
    setup [:create_connector]

    test "displays connector", %{conn: conn, connector: connector} do
      {:ok, _show_live, html} = live(conn, Routes.connector_show_path(conn, :show, connector))

      assert html =~ "Show Connector"
      assert html =~ connector.description
    end

    test "updates connector within modal", %{conn: conn, connector: connector} do
      {:ok, show_live, _html} = live(conn, Routes.connector_show_path(conn, :show, connector))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Connector"

      assert_patch(show_live, Routes.connector_show_path(conn, :edit, connector))

      assert show_live
             |> form("#connector-form", connector: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#connector-form", connector: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.connector_show_path(conn, :show, connector))

      assert html =~ "Connector updated successfully"
      assert html =~ "some updated description"
    end
  end
end
