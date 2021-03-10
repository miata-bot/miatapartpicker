defmodule PartpickerWeb.BuildController do
  use PartpickerWeb, :controller

  def index(conn, %{"discord_user_id" => discord_user_id}) do
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)

    if user do
      user = Partpicker.Repo.preload(user, builds: [:photos, :user])
      render(conn, "index.json", %{builds: user.builds, user: user})
    else
      conn
      |> put_status(404)
      |> render("error.json", error: "not found")
    end
  end

  def create(conn, %{"discord_user_id" => discord_user_id, "build" => attrs}) do
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)

    # what coudl go wrong lmao
    {:ok, user} =
      if user,
        do: {:ok, user},
        else:
          Partpicker.Accounts.register_user_with_oauth_discord(%{
            "id" => discord_user_id,
            "email" => nil
          })

    case Partpicker.Builds.create_build(user, attrs) do
      {:ok, build} ->
        build = Partpicker.Repo.preload(build, [:photos])
        render(conn, "show.json", %{build: %{build | user: user}})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("error.json", %{error: changeset})
    end
  end

  def show(conn, %{"discord_user_id" => discord_user_id, "uid" => build_uid}) do
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)

    if user do
      build = Partpicker.Builds.get_build_by_uid!(build_uid)
      render(conn, "show.json", %{build: %{build | user: user}})
    else
      conn
      |> put_status(404)
      |> render("error.json", error: "not found")
    end
  end

  def update(conn, %{"discord_user_id" => discord_user_id, "uid" => build_uid, "build" => attrs}) do
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)

    if user do
      build = Partpicker.Builds.get_build_by_uid!(build_uid)

      case Partpicker.Builds.update_build(build, attrs) do
        {:ok, build} ->
          render(conn, "show.json", %{build: %{build | user: user}})

        {:error, changeset} ->
          conn
          |> put_status(422)
          |> render("error.json", %{error: changeset})
      end
    else
      conn
      |> put_status(404)
      |> render("error.json", error: "not found")
    end
  end

  def banner(conn, %{
        "discord_user_id" => discord_user_id,
        "uid" => build_uid,
        "photo" => %{"attachment_url" => url}
      }) do
    import MiataBot.Carinfo, only: [download_image: 2]
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)

    if user do
      build = Partpicker.Builds.get_build_by_uid!(build_uid)
      filename = Path.basename(url)
      mime = MIME.from_path(filename)
      path = download_image(build, url)

      photo =
        %Partpicker.Builds.Photo{build_id: build.id}
        |> Partpicker.Builds.Photo.changeset(%{path: path, mime: mime, filename: filename})
        |> Partpicker.Repo.insert!()

      update(conn, %{
        "discord_user_id" => discord_user_id,
        "uid" => build_uid,
        "build" => %{"banner_photo_id" => photo.id}
      })
    else
      conn
      |> put_status(404)
      |> render("error.json", error: "not found")
    end
  end
end
