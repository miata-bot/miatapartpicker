defmodule PartpickerWeb.BuildLive.Show do
  use PartpickerWeb, :live_view

  alias Partpicker.Builds

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:user, user)}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:build, Builds.get_build!(socket.assigns.user, id))}
  end

  @impl true
  def handle_event("delete", %{"id" => _part_id}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "this doesn't work yet")}
  end

  defp page_title(:show), do: "Show Build"
  defp page_title(:edit), do: "Edit Build"
  defp page_title(:new_part), do: "New Part"
end
