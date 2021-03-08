defmodule PartpickerWeb.BuildLive.FormComponent do
  use PartpickerWeb, :live_component

  alias Partpicker.{Builds, Builds.Build}

  @impl true
  def update(%{build: build} = assigns, socket) do
    changeset = Builds.change_build(build)
    selected = if build.color, do: %{id: 0, name: build.color}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:selected, selected)
     |> assign(:suggestions, Build.colors_for(build))}
  end

  @impl true
  def handle_event(
        "validate",
        %{"search" => color_search, "build" => build_params},
        socket
      ) do
    changeset =
      socket.assigns.build
      |> Builds.change_build(build_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:suggestions, suggest(Build.colors_for(socket.assigns.build), color_search))}
  end

  def handle_event("validate", %{"build" => build_params}, socket) do
    changeset =
      socket.assigns.build
      |> Builds.change_build(build_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)}
  end

  def handle_event("select", %{"id" => id}, socket) do
    color = Build.color_by_id(socket.assigns.build, id)

    {:noreply,
     socket
     |> assign(:selected, color)}
  end

  def handle_event("clear", _, socket) do
    {:noreply,
     socket
     |> assign(:selected, nil)
     |> assign(:suggestions, Build.colors_for(socket.assigns.build))}
  end

  def handle_event("save", %{"build" => build_params}, socket) do
    save_build(socket, socket.assigns.action, build_params)
  end

  defp suggest(items, search) do
    Enum.filter(items, fn i ->
      i.name
      |> String.downcase()
      |> String.contains?(String.downcase(search))
    end)
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
    case Builds.create_build(socket.assigns.user, build_params) do
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
