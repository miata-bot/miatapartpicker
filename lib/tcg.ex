defmodule Partpicker.TCG do
  alias Ecto.Multi
  import Ecto.Query

  alias Partpicker.Repo

  alias Partpicker.TCG.{
          PrintingPlate,
          VirtualCard,
          PhysicalCard,
          TradeRequest
        },
        warn: false

  alias Partpicker.Accounts.User

  @endpoint PartpickerWeb.Endpoint

  def new_request(user) do
    user
    |> Ecto.build_assoc(:trade_requests)
    |> Ecto.Changeset.cast(%{}, [])
  end

  def offer_card(changeset, selected_card) do
    Ecto.Changeset.put_assoc(changeset, :offer, selected_card)
  end

  def select_receiver(changeset, receiver) do
    Ecto.Changeset.put_assoc(changeset, :receiver, receiver)
  end

  def receive_card(changeset, card_id) do
    receiver = Ecto.Changeset.get_field(changeset, :receiver)
    selected_card = get_card(receiver, card_id)
    Ecto.Changeset.put_assoc(changeset, :trade, selected_card)
  end

  def get_offer(changeset) do
    Ecto.Changeset.get_field(changeset, :offer)
  end

  def get_trade(changeset) do
    Ecto.Changeset.get_field(changeset, :trade)
  end

  def create_request(changeset) do
    with {:ok, request} <- Repo.insert(changeset) do
      request =
        Repo.preload(request, [
          :sender,
          :receiver,
          offer: [:printing_plate],
          trade: [:printing_plate]
        ])

      data = PartpickerWeb.TradeRequestView.render("show.json", %{trade_request: request})
      @endpoint.broadcast!("tcg", "CREATE_TRADE_REQUEST", data)
      {:ok, request}
    end
  end

  def print_virtual(%PrintingPlate{} = plate, %User{} = owner) do
    uuid = :crypto.strong_rand_bytes(4)

    %VirtualCard{
      printing_plate_id: plate.id,
      printing_plate: plate,
      user: owner,
      user_id: owner.id,
      uuid: uuid
    }
    |> Repo.insert()
  end

  def new_virtual_card(%PrintingPlate{} = plate) do
    uuid = :crypto.strong_rand_bytes(4)

    %VirtualCard{
      printing_plate_id: plate.id,
      printing_plate: plate,
      uuid: uuid
    }
  end

  def give_virtual_card(%VirtualCard{} = card, %User{} = owner) do
    %VirtualCard{
      card
      | user: owner,
        user_id: owner.id
    }
    |> Repo.insert()
  end

  def initiate_trade(
        %VirtualCard{user: %User{} = owner} = offer,
        %VirtualCard{user: %User{} = receiver} = trade
      ) do
    %TradeRequest{
      offer_id: offer.id,
      offer: offer,
      trade_id: trade.id,
      trade: trade,
      sender_id: owner.id,
      sender: owner,
      receiver_id: receiver.id,
      receiver: receiver,
      status: :pending
    }
    |> Repo.insert()
  end

  def accept_trade(
        %TradeRequest{
          offer: %VirtualCard{} = offer,
          trade: %VirtualCard{} = trade,
          sender: %User{} = offer_old_owner,
          receiver: %User{} = offer_new_owner,
          status: :pending
        } = trade_request
      ) do
    multi =
      Multi.new()
      |> Multi.update(:trade_request, TradeRequest.accept(trade_request))
      |> Multi.update(:offer, VirtualCard.exchange(offer, offer_new_owner))
      |> Multi.update(:trade, VirtualCard.exchange(trade, offer_old_owner))

    case Repo.transaction(multi) do
      {:ok, %{trade_request: trade_request}} -> {:ok, trade_request}
      {:error, _operation, _failed, _changes} = error -> error
    end
  end

  def reject_trade(%TradeRequest{} = trade_request) do
    trade_request
    |> TradeRequest.reject()
    |> Repo.update()
  end

  def get_card(user, id) do
    Partpicker.Repo.get_by!(Partpicker.TCG.VirtualCard, user_id: user.id, id: id)
    |> Partpicker.Repo.preload([:printing_plate])
  end

  def random_plate do
    Repo.one(from plate in PrintingPlate, order_by: fragment("RANDOM()"), limit: 1)
  end
end
