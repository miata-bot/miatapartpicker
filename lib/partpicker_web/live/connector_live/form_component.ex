defmodule PartpickerWeb.ConnectorLive.FormComponent do
  use PartpickerWeb, :live_component

  alias Partpicker.Library
  alias Partpicker.Library.Connector

  @impl true
  def update(%{connector: connector} = assigns, socket) do
    changeset =
      Library.change_connector(connector)
      |> Ecto.Changeset.put_embed(:links, [%Connector.Link{}])

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"connector" => connector_params}, socket) do
    changeset =
      socket.assigns.connector
      |> Library.change_connector(connector_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"connector" => connector_params}, socket) do
    save_connector(socket, socket.assigns.action, connector_params)
  end

  defp save_connector(socket, :edit, connector_params) do
    case Library.update_connector(socket.assigns.connector, connector_params) do
      {:ok, _connector} ->
        {:noreply,
         socket
         |> put_flash(:info, "Connector updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_connector(socket, :new, connector_params) do
    case Library.create_connector(connector_params) do
      {:ok, _connector} ->
        {:noreply,
         socket
         |> put_flash(:info, "Connector created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
