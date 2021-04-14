defmodule PartpickerWeb.AdminLive.Show do
  use PartpickerWeb, :live_view

  alias Partpicker.Accounts

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
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
    user = Accounts.get_user!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user, user)}
  end

  defp page_title(:show), do: "Show User"
  defp page_title(:edit), do: "Edit User"
end
