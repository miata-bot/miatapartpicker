defmodule Partpicker.Builds.Part.ImportJob do
  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: true}
  import Ecto.Changeset

  schema "part_imports" do
    belongs_to :build, Partpicker.Builds.Build
    field :path, :string, virtual: true
    field :completed_at_timestamp, :utc_datetime

    embeds_many :errors, Error do
      field :line, :integer
      field :message, :string
    end

    timestamps()
  end

  def changeset(part, attrs) do
    part
    |> cast(attrs, [:path, :completed_at_timestamp])
    |> validate_required([:path])
    |> cast_embed(:errors, with: {__MODULE__, :error_changeset, []})
  end

  def error_changeset(error, attrs) do
    error
    |> cast(attrs, [:line, :message])
    |> validate_required([:line, :message])
  end
end
