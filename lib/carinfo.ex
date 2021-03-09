defmodule MiataBot.Carinfo do
  use Ecto.Schema

  schema "carinfos" do
    field(:year, :integer)
    field(:color, :integer)
    field(:color_code, :string)
    field(:title, :string)
    field(:image_url, :string)
    field(:wheels, :string)
    field(:tires, :string)
    field(:discord_user_id, Snowflake)
    field(:instagram_handle, :string)
  end

  def import_all(carinfos, timeout \\ 15_000) do
    tasks =
      for carinfo <- carinfos do
        Task.async(fn -> import_carinfo(carinfo) end)
      end

    Task.yield_many(tasks, timeout)
  end

  def import_carinfo(carinfo) do
    user =
      if user = Partpicker.Accounts.get_user_by_discord_id(carinfo.discord_user_id) do
        user
      else
        Partpicker.Accounts.User.import_changeset(%Partpicker.Accounts.User{}, %{
          discord_user_id: carinfo.discord_user_id,
          instagram_handle: carinfo.instagram_handle
        })
        |> Partpicker.Repo.insert!()
      end

    {:ok, build} =
      Partpicker.Builds.create_build(user, %{
        year: carinfo.year,
        color: carinfo.color_code,
        description: carinfo.title,
        wheels: carinfo.wheels,
        tires: carinfo.tires
      })

    if carinfo.image_url do
      filename = Path.basename(carinfo.image_url)
      mime = MIME.from_path(filename)
      path = download_image(build, carinfo.image_url)

      %{id: uuid} =
        _photo =
        %Partpicker.Builds.Photo{build_id: build.id}
        |> Partpicker.Builds.Photo.changeset(%{path: path, mime: mime, filename: filename})
        |> Partpicker.Repo.insert!()

      Ecto.Changeset.change(build, %{banner_photo_id: uuid})
    end
  end

  def fix_all_banners(builds, timeout \\ 10_000) do
    tasks =
      for build <- builds do
        Task.async(fn -> fix_banner_photo(build) end)
      end

    Task.yield_many(tasks, timeout)
  end

  def fix_banner_photo(build) do
    case Partpicker.Repo.preload(build, :photos) do
      %Partpicker.Builds.Build{
        banner_photo_id: nil,
        photos: [%Partpicker.Builds.Photo{id: uuid} | _]
      } ->
        Ecto.Changeset.change(build, %{banner_photo_id: uuid})
        |> Partpicker.Repo.update!()

      %Partpicker.Builds.Build{banner_photo_id: _} ->
        :ok
    end
  end

  def download_image(build, url) do
    path =
      Partpicker.Builds.Photo.upload_path!(
        %Partpicker.Builds.Photo{build_id: build.id},
        %Phoenix.LiveView.UploadEntry{uuid: Ecto.UUID.generate()}
      )

    %{body: body} = Tesla.get!(url)
    File.write!(path, body)

    path
  end
end
