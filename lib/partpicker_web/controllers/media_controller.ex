defmodule PartpickerWeb.MediaController do
  use PartpickerWeb, :controller

  def show(conn, %{"uuid" => uuid}) do
    photo = Partpicker.Repo.get!(Partpicker.Builds.Photo, uuid)

    conn
    |> put_resp_content_type(photo.mime)
    |> send_file(200, photo.path)
  end
end
