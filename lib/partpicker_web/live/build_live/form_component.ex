defmodule PartpickerWeb.BuildLive.FormComponent do
  use PartpickerWeb, :live_component

  alias Partpicker.Builds

  @impl true
  def update(%{build: build} = assigns, socket) do
    changeset = Builds.change_build(build)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"build" => build_params}, socket) do
    changeset =
      socket.assigns.build
      |> Builds.change_build(build_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"build" => build_params}, socket) do
    save_build(socket, socket.assigns.action, build_params)
  end

  defp save_build(socket, :edit, build_params) do
    case Builds.update_build(socket.assigns.build, build_params) do
      {:ok, _build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_build(socket, :new, build_params) do
    case Builds.create_build(build_params) do
      {:ok, _build} ->
        {:noreply,
         socket
         |> put_flash(:info, "Build created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
