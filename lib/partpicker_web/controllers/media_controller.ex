defmodule PartpickerWeb.MediaController do
  use PartpickerWeb, :controller

  def show(conn, %{"uuid" => uuid}) do
    photo = Partpicker.Repo.get!(Partpicker.Builds.Photo, uuid)

    conn
    |> put_resp_content_type(photo.mime)
    |> send_file(200, photo.path)
  end

  use PhoenixSwagger

  swagger_path :show do
    get("/media")
    security([%{Bearer: []}])
    description("List users")
    response(200, "OK")

    parameters do
      photo_id(:path, :string, "photo ID", required: true)
    end
  end
end
