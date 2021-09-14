defmodule PartpickerWeb.PageLive do
  # use PartpickerWeb, :live_view
  use Surface.LiveView
  require Logger

  data current_user, :map

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        Logger.error("Unknown token")

        {:ok,
         socket
         |> redirect(external: PartpickerWeb.OAuth.Discord.authorization_url())}

      user ->
        {:ok,
         socket
         |> assign(:current_user, user)}
    end
  end

  def mount(_params, _, socket) do
    {:ok,
     socket
     |> redirect(external: PartpickerWeb.OAuth.Discord.authorization_url())}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:noreply,
     socket
     |> assign(:current_path, URI.parse(uri).path)}
  end
end
