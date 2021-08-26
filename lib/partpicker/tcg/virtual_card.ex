defmodule Partpicker.TCG.VirtualCard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tcg_virtual_cards" do
    belongs_to :printing_plate, Partpicker.TCG.PrintingPlate
    belongs_to :user, Partpicker.Accounts.User
    field :uuid, :binary, null: false
    timestamps()
  end

  def exchange(card, new_owner) do
    card
    |> cast(%{user_id: new_owner.id}, [:user_id])
  end
end
