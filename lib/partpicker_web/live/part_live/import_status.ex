defmodule PartpickerWeb.PartLive.ImportStatus do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Builds,
    Builds.Part.ImportJob
  }

  @impl true
  def mount(%{"import_job" => uuid}, _session, socket) do
    {:ok, socket}
  end
end
