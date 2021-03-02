defmodule Partpicker.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :tag, :string, null: false
    belongs_to :user, Partpicker.Accounts.User
    has_many :parts, Partpicker.List.Part

    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [])
    |> validate_required([])
    |> generate_tag()
    |> cast_assoc(:parts, with: &Partpicker.List.Part.changeset/2, on_replace: :nilify)
  end

  def generate_tag(changeset) do
    if get_field(changeset, :tag) do
      changeset
    else
      put_change(changeset, :tag, generate_tag_value())
    end
  end

  def generate_tag_value(), do: :crypto.strong_rand_bytes(3) |> Base.encode16(case: :lower)
end
