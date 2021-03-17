defmodule PartpickerWeb.PartLive.FormComponent do
  use PartpickerWeb, :live_component

  alias Partpicker.{Builds, Builds.Build, Builds.Part}

  @impl true
  def update(%{build: build} = assigns, socket) do
    changeset = Builds.change_part(%Part{build_id: build.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:part, %Part{build_id: build.id})}
  end

  @impl true
  def handle_event(
        "validate",
        %{"part" => part_params},
        socket
      ) do
    changeset =
      socket.assigns.part
      |> Builds.change_part(part_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"part" => part_params}, socket) do
    changeset =
      socket.assigns.part
      |> Builds.change_part(part_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"part" => part_params}, socket) do
    save_part(socket, socket.assigns.action, part_params)
  end

  defp save_part(socket, :edit, part_params) do
    case Builds.update_part(socket.assigns.part, part_params) do
      {:ok, _part} ->
        {:noreply,
         socket
         |> put_flash(:info, "Part updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_part(socket, :new_part, part_params) do
    case Builds.create_part(socket.assigns.build, part_params) do
      {:ok, _part} ->
        {:noreply,
         socket
         |> put_flash(:info, "Part added successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
