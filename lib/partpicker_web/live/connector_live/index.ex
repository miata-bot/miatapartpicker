defmodule PartpickerWeb.ConnectorLive.Index do
  use PartpickerWeb, :live_view

  alias Partpicker.Library
  alias Partpicker.Library.Connector

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:connectors, list_connectors())
         |> assign(:user, user)
         |> assign_meta()}
    end
  end

  def mount(_, _, socket) do
    {:ok,
     socket
     |> assign(:connectors, list_connectors())
     |> assign(:user, nil)
     |> assign_meta()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Connector")
    |> assign(:connector, Library.get_connector!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Connector")
    |> assign(:connector, %Connector{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Connectors")
    |> assign(:connector, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    connector = Library.get_connector!(id)
    {:ok, _} = Library.delete_connector(connector)

    {:noreply, assign(socket, :connectors, list_connectors())}
  end

  defp list_connectors do
    Library.list_connectors()
  end

  defp assign_meta(socket) do
    socket
    |> assign(:meta_description, "Electrical Connector Database for NA Miata")
  end
end
