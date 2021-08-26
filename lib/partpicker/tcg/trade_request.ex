defmodule Partpicker.TCG.TradeRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tcg_trade_requests" do
    belongs_to :offer, Partpicker.TCG.VirtualCard
    belongs_to :trade, Partpicker.TCG.VirtualCard
    belongs_to :sender, Partpicker.Accounts.User
    belongs_to :receiver, Partpicker.Accounts.User
    field :status, Ecto.Enum, values: [:accepted, :rejected, :pending], default: :pending
    timestamps()
  end

  def accept(request) do
    request
    |> cast(%{status: :accepted}, [:status])
  end

  def reject(request) do
    request
    |> cast(%{status: :accepted}, [:rejected])
  end
end
