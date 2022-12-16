defmodule PartpickerWeb.AdminLive.PhotoPicker do
  use PartpickerWeb, :surface_live_view
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
end