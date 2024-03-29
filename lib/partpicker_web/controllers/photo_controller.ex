defmodule PartpickerWeb.PhotoController do
  use PartpickerWeb, :controller

  def random(conn, %{"discord_user_ids" => ids}) do
    photo = Partpicker.Builds.random_photo(ids)
    render(conn, "show.json", %{photo: photo})
  end

  use PhoenixSwagger

  def swagger_definitions do
    %{
      PhotoMeta:
        swagger_schema do
          title("hoto metadata")

          properties do
            format(:string, "file format", required: true)
            width(:number, "photo width in pixels", required: true)
            height(:number, "photo height in pixels", required: true)
            animated(:boolean, "animation flag", required: true)
            frame_count(:boolean, "number of frames in an animation ", required: true)
          end
        end,
      Photo:
        swagger_schema do
          title("Photo descriptor")

          properties do
            uuid(:string, "unique id for a photo", required: true)
            filename(:string, "unique id for a photo", required: true)
            meta(Schema.ref(:PhotoMeta), "metadata for a photo", required: true)
          end
        end
    }
  end

  swagger_path :random do
    tag("Media")
    post("/api/photos/random")
    security([%{Bearer: []}])
    description("get a random photo")

    parameters do
      discord_user_ids(:body, :array, "array of discord ids")
    end

    response(200, "OK", Schema.ref(:Photo))
  end
end
