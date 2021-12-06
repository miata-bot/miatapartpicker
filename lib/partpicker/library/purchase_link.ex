defmodule Partpicker.Library.PurchaseLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "purchase_links" do
    field :url, :string, null: false
    timestamps()
  end

  def changeset(purchase_link, attrs \\ %{}) do
    purchase_link
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> unique_constraint([:url])
  end
end
