defmodule PartpickerWeb.PhotoView do
  use PartpickerWeb, :view
  alias PartpickerWeb.PhotoView, warn: false

  def render("show.json", %{photo: photo}) do
    %{uuid: photo.id, filename: photo.filename}
  end
end
