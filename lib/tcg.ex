defmodule Partpicker.TCG do
  alias Ecto.Multi

  alias Partpicker.Repo

  alias Partpicker.TCG.{
          PrintingPlate,
          VirtualCard,
          PhysicalCard,
          TradeRequest
        },
        warn: false

  alias Partpicker.Accounts.User

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
end
