defmodule PartpickerWeb.LayoutView do
  use PartpickerWeb, :view

  def active?(conn, "/") do
    match?({PartpickerWeb.PageLive, _}, conn.private[:phoenix_live_view]) ||
      conn.private[:phoenix_controller] == PartpickerWeb.PageLive
  end

  def active?(conn, "/list" <> _) do
    match?({PartpickerWeb.ListLive, _}, conn.private[:phoenix_live_view]) ||
      conn.private[:phoenix_controller] == PartpickerWeb.ListLive
  end

  def active?(_conn, _link) do
    false
  end
end
