defmodule PartpickerWeb.PhotoController do
  use PartpickerWeb, :controller

  def random(conn, %{"discord_user_ids" => ids}) do
    photo = Partpicker.Builds.random_photo(ids)
    render(conn, "show.json", %{photo: photo})
  end
end
