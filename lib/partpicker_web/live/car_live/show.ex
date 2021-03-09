defmodule PartpickerWeb.CarLive.Show do
  use PartpickerWeb, :live_view

  alias Partpicker.Builds

  @impl true
  def mount(%{"uid" => uid}, _session, socket) do
    build = Builds.get_build_by_uid!(uid)

    {:ok,
     socket
     |> assign(:build, build)
     |> assign_meta()}
  end

  def assign_meta(
        %{
          assigns: %{
            build: build = %{banner_photo_id: banner_photo_id, user: %{discord_oauth_info: info}}
          }
        } = socket
      ) do
    banner_photo = Partpicker.Repo.get!(Partpicker.Builds.Photo, banner_photo_id)

    socket
    |> assign(:meta_description, build.description || "")
    |> assign(:meta_image, Routes.media_url(socket, :show, banner_photo_id))
    |> assign(:meta_image_type, banner_photo.mime)
    |> assign_discord_oauth_info(info)
  end

  def assign_meta(socket) do
    socket
  end

  def assign_discord_oauth_info(socket, nil) do
    socket
    |> assign(:meta_title, "Unknown user")
    |> assign(:meta_description, """
    The owner of this vehicle has not claimed this vehicle
    """)
  end

  def assign_discord_oauth_info(socket, info) do
    socket
    |> assign(:meta_title, "@#{info.username}#{info.discriminator}")
  end
end
