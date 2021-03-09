defmodule PartpickerWeb.BuildLive.Index do
  use PartpickerWeb, :live_view

  alias Partpicker.Builds
  alias Partpicker.Builds.Build

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:builds, list_builds(user))
         |> assign(:user, user)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Build")
    |> assign(:build, Builds.get_build!(socket.assigns.user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Build")
    |> assign(:build, %Build{user_id: socket.assigns.user.id, photos: []})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Builds")
    |> assign(:build, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    build = Builds.get_build!(socket.assigns.user, id)
    {:ok, _} = Builds.delete_build(build)

    {:noreply, assign(socket, :builds, list_builds(socket.assigns.user))}
  end

  defp list_builds(user) do
    Builds.list_builds(user)
  end
end
