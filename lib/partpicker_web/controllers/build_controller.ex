defmodule PartpickerWeb.BuildController do
  use PartpickerWeb, :controller

  def index(conn, %{"discord_user_id" => discord_user_id}) do
    user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)
    user = Partpicker.Repo.preload(user, builds: [:photos])
    render(conn, "index.json", %{builds: user.builds})
  end

  def show(conn, %{"discord_user_id" => discord_user_id, "uid" => build_uid}) do
    _user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)
    build = Partpicker.Builds.get_build_by_uid!(build_uid)
    render(conn, "show.json", %{build: build})
  end

  def update(conn, %{"discord_user_id" => discord_user_id, "uid" => build_uid, "build" => attrs}) do
    _user = Partpicker.Accounts.get_user_by_discord_id(discord_user_id)
    build = Partpicker.Builds.get_build_by_uid!(build_uid)

    case Partpicker.Builds.update_build(build, attrs) do
      {:ok, build} ->
        render(conn, "show.json", %{build: build})

      {:error, changeset} ->
        render(conn, "error.json", %{error: changeset})
    end
  end
end
