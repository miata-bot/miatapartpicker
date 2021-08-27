defmodule PartpickerWeb.CardLive.Offers do
  use PartpickerWeb, :live_view
  alias Partpicker.TCG

  @impl true
  def mount(_, %{"user_token" => token}, socket) do
    case Partpicker.Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, socket}

      user ->
        {:ok,
         socket
         |> assign(:user, load_user(user))
         |> assign(:trade_requests, list_trade_requests(user))}
    end
  end

  @impl true
  def handle_event("trade_accept", %{"trade_request_id" => trade_request_id}, socket) do
    request = get_request(socket.assigns.user, trade_request_id)

    case TCG.accept_trade(request) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request accepted")
         |> assign(:user, load_user(socket.assigns.user))
         |> assign(:trade_requests, list_trade_requests(socket.assigns.user))}

      _error ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to accept request")
         |> assign(:user, load_user(socket.assigns.user))
         |> assign(:trade_requests, list_trade_requests(socket.assigns.user))}
    end
  end

  def handle_event("trade_decline", %{"trade_request_id" => trade_request_id}, socket) do
    get_request(socket.assigns.user, trade_request_id)

    {:noreply,
     socket
     |> put_flash(:error, "no")
     |> assign(:user, load_user(socket.assigns.user))
     |> assign(:trade_requests, list_trade_requests(socket.assigns.user))}
  end

  def get_request(user, trade_request_id) do
    Partpicker.Repo.get_by!(TCG.TradeRequest, receiver_id: user.id, id: trade_request_id)
    |> Partpicker.Repo.preload([
      :sender,
      :receiver,
      offer: [:printing_plate],
      trade: [:printing_plate]
    ])
  end

  def load_user(user) do
    Partpicker.Repo.preload(user,
      trade_requests: [
        :sender,
        :receiver,
        offer: [:printing_plate],
        trade: [:printing_plate]
      ]
    )
  end

  def list_trade_requests(user) do
    import Ecto.Query

    Partpicker.Repo.all(from tr in Partpicker.TCG.TradeRequest, where: tr.receiver_id == ^user.id)
    |> Partpicker.Repo.preload([
      :sender,
      :receiver,
      offer: [:printing_plate],
      trade: [:printing_plate]
    ])
  end
end
