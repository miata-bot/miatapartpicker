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
         |> assign(:user, user)
         |> assign(:users, Partpicker.Accounts.list_users())
         |> assign(:trade, "")
         |> assign(:trade_selection, nil)}
    end
  end

  @impl true
  def handle_event("create_trade", %{}, socket) do
    {:noreply,
     socket
     |> assign(:trade, "Select a card to offer")}
  end

  def handle_event("trade_select", %{"card_id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:trade, "Search for a user by their discord username")
     |> assign(:trade_selection, get_card(socket.assigns.user, id))
     |> assign(:cards, [])}
  end

  def handle_event("user_select", %{"user_id" => user_id}, socket) do
    user = Partpicker.Accounts.get_user!(user_id)

    {:noreply,
     socket
     |> assign(:trade, "Select a card to trade for")
     |> assign(:cards, list_cards(user))}
  end

  def handle_event("validate", %{"trade" => %{"search" => ""}}, socket) do
    {:noreply,
     socket
     |> assign(:users, Partpicker.Accounts.list_users())}
  end

  def handle_event("validate", %{"trade" => %{"search" => input}}, socket) do
    users =
      Enum.sort(socket.assigns.users, fn
        %{discord_oauth_info: %{username: a}}, %{discord_oauth_info: %{username: b}} ->
          String.jaro_distance(to_string(a), to_string(input)) >=
            String.jaro_distance(to_string(b), to_string(input))

        _, _ ->
          false
      end)

    {:noreply,
     socket
     |> assign(:users, users)}
  end

  def list_cards(user) do
    Partpicker.Repo.preload(user, cards: [:printing_plate]).cards
  end

  def get_card(user, id) do
    Partpicker.Repo.get_by!(Partpicker.TCG.VirtualCard, user_id: user.id, id: id)
    |> Partpicker.Repo.preload([:printing_plate])
  end
end
