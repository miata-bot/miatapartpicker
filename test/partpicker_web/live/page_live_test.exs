defmodule PartpickerWeb.PageLiveTest do
  use PartpickerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "This page will have some useful"
    assert render(page_live) =~ "This page will have some useful"
  end
end
