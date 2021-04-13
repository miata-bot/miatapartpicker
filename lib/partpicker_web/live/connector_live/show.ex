defmodule PartpickerWeb.ConnectorLive.Show do
  use PartpickerWeb, :live_view

  alias Partpicker.Library

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:user, user)}
    end
  end

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:user, nil)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    connector = Library.get_connector!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:connector, connector)
     |> assign_meta(connector)}
  end

  defp page_title(:show), do: "Show Connector"
  defp page_title(:edit), do: "Edit Connector"

  defp assign_meta(socket, connector) do
    socket
    |> assign(:meta_description, connector.description || "")
    |> assign(:meta_image, Routes.static_path(socket, "/images/connectors/#{connector.name}.png"))
    |> assign(:meta_image_type, "image/png")
  end
end
