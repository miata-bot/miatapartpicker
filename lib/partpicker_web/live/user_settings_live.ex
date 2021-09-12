defmodule PartpickerWeb.UserSettingsLive do
  use PartpickerWeb, :surface_live_view

  alias Partpicker.Accounts
  require Logger

  data current_user, :map
  data changeset, :map

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        Logger.error("Unknown token")

        {:ok,
         socket
         |> redirect(external: PartpickerWeb.OAuth.Discord.authorization_url())}

      user ->
        changeset = Accounts.change_settings(user)

        {:ok,
         socket
         |> assign(:current_user, user)
         |> assign(:changeset, changeset)}
    end
  end

  def mount(_params, _, socket) do
    {:ok,
     socket
     |> redirect(external: PartpickerWeb.OAuth.Discord.authorization_url())}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_settings(socket.assigns.changeset, user_params)
    {:noreply, socket |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.update_settings(socket.assigns.current_user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Updated settings")
         |> assign(:current_user, user)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "There were errors. see below")
         |> assign(:changeset, changeset)}
    end
  end
end
