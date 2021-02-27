defmodule PartpickerWeb.ProductManageLive do
  use PartpickerWeb, :live_view

  alias Partpicker.{
    Lists,
    List.Selection
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:selection, %Selection{})
     |> assign(:changeset, Lists.change_selection(%Selection{}))}
  end

  @impl true
  def handle_event("validate", %{"selection" => attrs}, socket) do
    changeset = Lists.change_selection(socket.assigns.selection, attrs)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"selection" => attrs}, socket) do
    case Lists.new_selection(attrs) do
      {:ok, selection} ->
        {:noreply,
         socket
         |> put_flash(:info, "Created selection!")
         |> assign(:selection, selection)
         |> assign(:changeset, Lists.change_selection(selection))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error creating selection")
         |> assign(:changeset, changeset)}
    end
  end
end
