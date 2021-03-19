defmodule Partpicker.Builds.Photo do
  use Ecto.Schema
  import Ecto.Changeset
  alias Partpicker.Builds.Photo

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "photos" do
    belongs_to :build, Partpicker.Builds.Build
    field :path, :string, null: false
    field :filename, :string
    field :mime, :string
    timestamps()
  end

  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:path, :mime, :filename])
    |> validate_required([:path])
  end

  # :ok = File.cp!(path, Photo.upload_path(%Photo{build_id: socket.assigns.build.id}, path, entry))
  def upload_path!(%Photo{build_id: nil}, _entry), do: raise(ArgumentError)

  def upload_path!(%Photo{build_id: build_id}, %Phoenix.LiveView.UploadEntry{uuid: uuid}) do
    dir = Path.join([root_path(), to_string(build_id)])
    _ = File.mkdir_p(dir)
    Path.join(dir, uuid)
  end

  def root_path,
    do:
      Application.get_env(:partpicker, __MODULE__)[:root_path] ||
        raise("root_path unconfigured for photo uploads")
end
