defmodule PartpickerWeb.CarLive.Show do
  use PartpickerWeb, :live_view

  alias Partpicker.Builds

  @impl true
  def mount(%{"uid" => uid}, _session, socket) do
    build = Builds.get_build_by_uid!(uid)

    {:ok,
     socket
     |> assign(:build, build)}
  end
end
