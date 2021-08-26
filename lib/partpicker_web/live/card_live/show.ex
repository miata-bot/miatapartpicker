defmodule PartpickerWeb.CardLive.Show do
  use PartpickerWeb, :live_view

  @impl true
  def mount(%{"id" => id}, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:card, get_card(user, id))
         |> assign(:user, user)}
    end
  end

  def get_card(user, id) do
    Partpicker.Repo.get_by!(Partpicker.TCG.VirtualCard, user_id: user.id, id: id)
    |> Partpicker.Repo.preload([:printing_plate])
  end
end
