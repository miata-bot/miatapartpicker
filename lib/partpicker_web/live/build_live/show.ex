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
  def handle_event("delete", %{"id" => part_id}, socket) do
    with %Builds.Part{} = part <- Builds.get_part(socket.assigns.build, part_id),
         {:ok, %Builds.Part{} = _part} <- Builds.delete_part(part) do
      {:noreply,
       socket
       |> put_flash(:info, "Deleted part")
       |> assign(:build, Builds.get_build!(socket.assigns.user, socket.assigns.build.id))}
    else
      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to delete part")}
    end
  end

  defp page_title(:show), do: "Show Build"
  defp page_title(:edit), do: "Edit Build"
  defp page_title(:new_part), do: "New Part"
end
