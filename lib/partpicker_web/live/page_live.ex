defmodule PartpickerWeb.PageLive do
  # use PartpickerWeb, :live_view
  use Surface.LiveView

  data current_user, :map

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:current_user, user)}
    end
  end

  def mount(_params, _, socket) do
    {:ok, socket}
  end
end
