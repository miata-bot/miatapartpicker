defmodule PartpickerWeb.TradeRequestView do
  use PartpickerWeb, :view

  def render("show.json", %{trade_request: trade_request}) do
    %{
      offer: %{
        uuid: Base.encode16(trade_request.offer.uuid, case: :upper),
        asset_url: asset_url(trade_request.offer)
      },
      trade: %{
        uuid: Base.encode16(trade_request.trade.uuid, case: :upper),
        asset_url: asset_url(trade_request.trade)
      },
      sender: trade_request.sender.discord_user_id,
      receiver: trade_request.receiver.discord_user_id,
      status: trade_request.status,
      inserted_at: trade_request.inserted_at,
      updated_at: trade_request.updated_at
    }
  end

  def asset_url(virtual_card) do
    Routes.static_url(@endpoint, "/images/" <> virtual_card.printing_plate.filename)
  end
end
