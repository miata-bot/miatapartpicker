defmodule PartpickerWeb.BuildController do
  use PartpickerWeb, :controller

  def index(conn, %{"user_id" => discord_user_id}) do
    user =
      Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)
      |> Partpicker.Repo.preload(builds: [:photos, :user], featured_build: [:build])
      |> Map.update!(:builds, fn builds ->
        Enum.map(builds, &Partpicker.Builds.Build.calculate_mileage/1)
      end)

    render(conn, "index.json", %{builds: user.builds})
  end

  def create(conn, %{"user_id" => discord_user_id, "build" => attrs}) do
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)

    case Partpicker.Builds.create_build(user, attrs) do
      {:ok, build} ->
        build = Partpicker.Repo.preload(build, [:photos])

        conn
        |> put_status(:created)
        |> render("show.json", %{build: build})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{error: changeset})
    end
  end

  def show(conn, %{"user_id" => discord_user_id, "id" => build_uid}) do
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)
    build = Partpicker.Builds.get_build_by_uid!(user, build_uid)
    render(conn, "show.json", %{build: build})
  end

  def update(conn, %{"user_id" => discord_user_id, "id" => build_uid, "build" => attrs}) do
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)
    build = Partpicker.Builds.get_build_by_uid!(user, build_uid)

    case Partpicker.Builds.update_build(build, attrs) do
      {:ok, build} ->
        conn
        |> put_status(:accepted)
        |> render("show.json", %{build: build})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{error: changeset})
    end
  end

  def banner(conn, %{
        "user_id" => discord_user_id,
        "build_id" => build_uid,
        "photo" => %{"attachment_url" => url}
      }) do
    import MiataBot.Carinfo, only: [download_image: 2]
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)

    build = Partpicker.Builds.get_build_by_uid!(user, build_uid)
    filename = Path.basename(url)
    mime = MIME.from_path(filename)
    path = download_image(build, url)

    photo =
      %Partpicker.Builds.Photo{build_id: build.id}
      |> Partpicker.Builds.Photo.changeset(%{path: path, mime: mime, filename: filename})
      |> Partpicker.Repo.insert!()

    update(conn, %{
      "user_id" => discord_user_id,
      "id" => build_uid,
      "build" => %{"banner_photo_id" => photo.id}
    })
  end
end
