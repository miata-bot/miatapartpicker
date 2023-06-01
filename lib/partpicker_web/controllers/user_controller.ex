defmodule PartpickerWeb.UserController do
  use PartpickerWeb, :controller

  def index(conn, _params) do
    users = Partpicker.Accounts.list_users()
    render(conn, "index.json", %{users: users})
  end

  def create(conn, %{"user" => user_attrs}) do
    case Partpicker.Accounts.api_register_user(user_attrs) do
      {:ok, user} ->
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

  use PhoenixSwagger

  def swagger_definitions do
    %{
      Build:
        swagger_schema do
          title("Build")
          description("describes a car ig")
        end,
      Builds:
        swagger_schema do
          type(:array)
          items(Schema.ref(:Build))
        end,
      Cards:
        swagger_schema do
          title("Card")
          description("please just ignore this")
        end,
      User:
        swagger_schema do
          title("User")
          description("A user of the application")

          properties do
            discord_user_id(:string, "Users Discord ID", required: true)
            instagram_handle(:string, "Users Instagram Handle")
            builds(Schema.ref(:Builds), "list of all builds")
            cards(Schema.ref(:Cards), "dead feature")
            featured_build(Schema.ref(:Build), "users build")
            foot_size(:integer, "foot size")
            hand_size(:integer, "hand size")
            preferred_unit(:string, "miles or km")
            preferred_timezone(:string, "timezone")
            steam_id(:string, "dead feature")
          end
        end,
      Users:
        swagger_schema do
          title("Users")
          type(:array)
          items(Schema.ref(:User))
        end
    }
  end

  swagger_path :index do
    get("/api/users")
    security([%{Bearer: []}])
    description("List users")
    response(200, "OK", Schema.ref(:Users))
  end
end
