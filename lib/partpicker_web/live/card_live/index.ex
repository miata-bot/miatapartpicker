defmodule PartpickerWeb.CardLive.Index do
  use PartpickerWeb, :live_view
  alias Partpicker.{TCG, TCG.TradeRequest}

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok, reset_assigns(socket, user)}
    end
  end

  @impl true
  def handle_event("create_trade_request", _, socket) do
    changeset =
      socket.assigns.user
      |> Ecto.build_assoc(:trade_requests)
      |> Ecto.Changeset.cast(%{}, [])

    {:noreply,
     socket
     |> assign(:banner, "Select a card to offer")
     |> assign(:changeset, changeset)}
  end

  def handle_event("submit_trade_request", _, socket) do
    case Partpicker.Repo.insert(socket.assigns.changeset) do
      {:ok, request} ->
        IO.inspect(request, label: "REQUEST")

        {:noreply,
         socket
         |> reset_assigns(socket.assigns.user)
         |> put_flash(:info, "Trade request has been submitted")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to submit trade request")
         |> assign(:changeset, changeset)}
    end
  end

  def handle_event(
        "card_select",
        %{"card_id" => id},
        %{assigns: %{receiver_selected: false}} = socket
      ) do
    selected_card = get_card(socket.assigns.user, id)
    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :offer, selected_card)

    {:noreply,
     socket
     |> assign(:banner, "Search for a user by their discord username")
     |> assign(:changeset, changeset)
     |> assign(:cards, [selected_card])
     |> assign(:offer_selected, true)
     |> assign(:user_search, true)}
  end

  def handle_event(
        "card_select",
        %{"card_id" => id},
        %{assigns: %{receiver_selected: true}} = socket
      ) do
    receiver = Ecto.Changeset.get_field(socket.assigns.changeset, :receiver)
    selected_card = get_card(receiver, id)

    offer = Ecto.Changeset.get_field(socket.assigns.changeset, :offer)
    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :trade, selected_card)

    {:noreply,
     socket
     |> assign(:banner, "Review trade")
     |> assign(:changeset, changeset)
     |> assign(:cards, [offer, selected_card])
     |> assign(:ready_to_submit, true)}
  end

  def handle_event("card_select", %{"card_id" => _id}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "That shouldn't be possible...")}
  end

  def handle_event("user_search", %{"user_search" => %{"user_search" => ""}}, socket) do
    {:noreply,
     socket
     |> assign(:users, Partpicker.Accounts.list_users())}
  end

  def handle_event("user_search", %{"user_search" => %{"user_search" => input}}, socket) do
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

  def handle_event("user_select", %{"user_id" => user_id}, socket) do
    receiver = Partpicker.Accounts.get_user!(user_id)
    changeset = Ecto.Changeset.put_assoc(socket.assigns.changeset, :receiver, receiver)

    {:noreply,
     socket
     |> assign(:banner, "Select a card to trade for")
     |> assign(:users, [receiver])
     |> assign(:cards, list_cards(receiver))
     |> assign(:receiver_selected, true)
     |> assign(:changeset, changeset)}
  end

  def list_cards(user) do
    Partpicker.Repo.preload(user, cards: [:printing_plate]).cards
  end

  def get_card(user, id) do
    Partpicker.Repo.get_by!(Partpicker.TCG.VirtualCard, user_id: user.id, id: id)
    |> Partpicker.Repo.preload([:printing_plate])
  end

  def reset_assigns(socket, user) do
    socket
    |> assign(:cards, list_cards(user))
    |> assign(:user, user)
    |> assign(:users, Partpicker.Accounts.list_users())
    |> assign(:banner, "Your Inventory")
    |> assign(:changeset, nil)
    |> assign(:offer_selected, false)
    |> assign(:receiver_selected, false)
    |> assign(:user_search, false)
    |> assign(:ready_to_submit, false)
  end
end
