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
end
