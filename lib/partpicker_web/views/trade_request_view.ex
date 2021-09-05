defmodule PartpickerWeb.TradeRequestView do
  use PartpickerWeb, :view

  def render("show.json", %{trade_request: trade_request}) do
    %{
      offer: PartpickerWeb.CardView.render("show.json", %{card: trade_request.offer}),
      trade: PartpickerWeb.CardView.render("show.json", %{card: trade_request.trade}),
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
