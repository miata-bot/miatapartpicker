defmodule PartpickerWeb.CardView do
  use PartpickerWeb, :view

  def render("show.json", %{card: card}) do
    %{
      id: Base.encode16(card.uuid, case: :upper),
      asset_url: Routes.static_url(@endpoint, "/images/" <> card.printing_plate.filename)
    }
  end
end
