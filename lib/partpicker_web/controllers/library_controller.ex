defmodule PartpickerWeb.LibraryController do
  use PartpickerWeb, :controller
  alias Partpicker.Library

  def index(conn, _) do
    chassis = Library.list_chassis()
    render(conn, "index.html", chassis: chassis)
  end
end
