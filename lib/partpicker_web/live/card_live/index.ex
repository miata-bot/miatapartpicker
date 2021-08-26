defmodule PartpickerWeb.CardLive.Index do
  use PartpickerWeb, :live_view

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:cards, list_cards(user))
         |> assign(:user, user)}
    end
  end

  def list_cards(user) do
    Partpicker.Repo.preload(user, cards: [:printing_plate]).cards
  end
end
