defmodule PartpickerWeb.CardController do
  use PartpickerWeb, :controller
  alias Partpicker.TCG
  alias Partpicker.Accounts

  def generate_random_offer(conn, _params) do
    random_card = TCG.RandomCardGenerator.generate()

    conn
    |> put_status(:accepted)
    |> render("show.json", %{card: random_card})
  end

  def claim_random_offer(conn, %{"card_id" => uuid, "user_id" => discord_user_id}) do
    user = Accounts.get_user_by_discord_id!(discord_user_id)

    case TCG.RandomCardGenerator.claim(uuid, user) do
      {:ok, card} ->
        {:ok, card} = TCG.give_virtual_card(card, user)

        conn
        |> put_status(:created)
        |> render("show.json", %{card: card})

      _ ->
        conn
        |> put_status(404)
        |> render("error.json", %{error: "Unknown card or already claimed card"})
    end
  end
end
