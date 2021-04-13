defmodule PartpickerWeb.ConnectorLive.Show do
  use PartpickerWeb, :live_view

  alias Partpicker.Library

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:connector, Library.get_connector!(id))}
  end

  defp page_title(:show), do: "Show Connector"
  defp page_title(:edit), do: "Edit Connector"
end
