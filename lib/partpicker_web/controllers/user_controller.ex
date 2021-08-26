defmodule PartpickerWeb.UserController do
  use PartpickerWeb, :controller

  def create(conn, %{"user" => user_attrs}) do
    case Partpicker.Accounts.api_register_user(user_attrs) do
      {:ok, user} ->
        user =
          Partpicker.Repo.preload(user,
            builds: [:photos],
            featured_build: [build: [:photos]],
            cards: [:printing_plate]
          )

        conn
        |> put_status(:created)
        |> render("show.json", %{user: user})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("error.json", %{error: changeset})
    end
  end

  def update(conn, %{"id" => discord_user_id, "user" => user_params}) do
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)

    case Partpicker.Accounts.api_change_user(user, user_params) do
      {:ok, user} ->
        user =
          Partpicker.Repo.preload(user,
            builds: [:photos],
            featured_build: [build: [:photos]],
            cards: [:printing_plate]
          )

        conn
        |> put_status(:accepted)
        |> render("show.json", %{user: user})

      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render("error.json", %{error: changeset})
    end
  end

  def show(conn, %{"id" => discord_user_id}) do
    user =
      Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)
      |> Partpicker.Repo.preload(
        builds: [:photos],
        featured_build: [build: [:photos]],
        cards: [:printing_plate]
      )

    render(conn, "show.json", %{user: user})
  end

  def featured_build(conn, %{"user_id" => discord_user_id, "featured_build_id" => build_uid}) do
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)
    build = Partpicker.Builds.get_build_by_uid!(user, build_uid)
    _featured_build = Partpicker.Builds.create_featured_build!(user, build)

    user =
      Partpicker.Repo.preload(user,
        builds: [:photos],
        featured_build: [build: [:photos]],
        cards: [:printing_plate]
      )

    conn
    |> put_status(:accepted)
    |> render("show.json", %{user: user})
  end
end
