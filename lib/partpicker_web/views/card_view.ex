defmodule PartpickerWeb.CardView do
  use PartpickerWeb, :view

  def render("show.json", %{card: card}) do
    %{
      id: Base.encode16(card.uuid, case: :upper),
      asset_url: Routes.static_url(@endpoint, "/images/" <> card.printing_plate.filename)
    }
  end

  def render("error.json", %{error: %Ecto.Changeset{} = changeset}) do
    %{
      status: "failure",
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def render("error.json", %{error: error}) do
    %{
      status: "failure",
      errors: [error]
    }
  end
end
