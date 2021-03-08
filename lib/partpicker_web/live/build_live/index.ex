defmodule PartpickerWeb.BuildLive.Index do
  use PartpickerWeb, :live_view

  alias Partpicker.Builds
  alias Partpicker.Builds.Build

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :builds, list_builds())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Build")
    |> assign(:build, Builds.get_build!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Build")
    |> assign(:build, %Build{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Builds")
    |> assign(:build, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    build = Builds.get_build!(id)
    {:ok, _} = Builds.delete_build(build)

    {:noreply, assign(socket, :builds, list_builds())}
  end

  defp list_builds do
    Builds.list_builds()
  end
end
