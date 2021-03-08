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

  def active_class,
    do: "inline-block py-2 px-4 text-gray-900 no-underline bg-gray-600 border rounded-full"

  def unactive_class,
    do: "inline-block text-gray-500 no-underline hover:text-white hover:text-underline py-2 px-4"
end
