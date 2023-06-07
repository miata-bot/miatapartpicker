defmodule PartpickerWeb.UserController do
  use PartpickerWeb, :controller
  require Logger

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

  def oauth(conn, %{"user" => me} = params) do
    case Partpicker.Accounts.get_user_by_discord_id(me["id"]) do
      nil ->
        with {:ok, user} <-
               Partpicker.Accounts.oauth_discord_register_user(me, params["connections"] || []) do
          Logger.info("Created user from discord: #{inspect(user)}")

          conn
          |> put_status(:created)
          |> render("show.json", %{user: user})
        else
          {:error, changeset} ->
            conn
            |> put_status(422)
            |> render("error.json", %{error: changeset})
        end

      user ->
        with {:ok, user} <-
               Partpicker.Accounts.update_discord_oauth_info(
                 user,
                 me,
                 params["connections"] || []
               ) do
          Logger.info("Logged in #{inspect(params["connections"] || [])}")

          conn
          |> put_status(:accepted)
          |> render("show.json", %{user: user})
        else
          {:error, changeset} ->
            conn
            |> put_status(422)
            |> render("error.json", %{error: changeset})
        end
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
      |> Map.update(:builds, [], fn builds ->
        Enum.map(builds, &Partpicker.Builds.identify_photos/1)
      end)
      |> Map.update(:featured_build, nil, fn featured_build ->
        %{featured_build | build: Partpicker.Builds.identify_photos(featured_build.build)}
      end)

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
        end,
      UserCreate:
        swagger_schema do
          title("User create")
          description("called internally by miatabot, only necessary for testing/hacking")

          properties do
            discord_user_id(:string, "Users Discord ID", required: true)
            instagram_handle(:string, "Users Instagram Handle")
            foot_size(:integer, "foot size")
            hand_size(:integer, "hand size")
            preferred_unit(:string, "miles or km")
            preferred_timezone(:string, "timezone")
          end
        end,
      UserDiscordOauth:
        swagger_schema do
          title("discord user oauth")
          description("call with the `me` payload from discord oauth")

          properties do
            id(:string, "discord id")
          end
        end,
      UserDiscordOauthConnections:
        swagger_schema do
          title("discord user oauth connections")
          description("call with the `me` payload from discord oauth")

          properties do
          end
        end
    }
  end

  swagger_path :index do
    tag("Users")
    get("/api/users")
    security([%{Bearer: []}])
    description("List users")
    response(200, "OK", Schema.ref(:Users))
  end

  swagger_path :create do
    tag("Users")
    post("/api/users")
    security([%{Bearer: []}])
    description("create a user")

    parameters do
      user(:body, Schema.ref(:UserCreate), "user attributes")
    end

    response(200, "OK", Schema.ref(:User))
  end

  swagger_path :oauth do
    tag("Users")
    post("/api/users/oauth")
    security([%{Bearer: []}])
    description("create a user by oauthing")

    parameters do
      me(:body, Schema.ref(:UserDiscordOauth), "user attributes", required: true)
      connections(:body, Schema.ref(:UserDiscordOauthConnections), "user attributes")
    end

    response(200, "OK", Schema.ref(:User))
  end

  swagger_path :show do
    tag("Users")
    get("/api/users/:user_id")
    security([%{Bearer: []}])
    description("update a user")

    parameters do
      user_id(:path, :string, "user discord id", required: true)
    end

    response(200, "OK", Schema.ref(:User))
  end

  swagger_path :update do
    tag("Users")
    put("/api/users/:user_id")
    security([%{Bearer: []}])
    description("update a user")

    parameters do
      user_id(:path, :string, "user discord id", required: true)
      user(:body, Schema.ref(:UserCreate), "user attributes", required: true)
    end

    response(200, "OK", Schema.ref(:User))
  end

  swagger_path :featured_build do
    tag("Users")
    put("/api/users/:user_id/featured_build")
    security([%{Bearer: []}])
    description("set a users featured build by it's id")

    parameters do
      user_id(:path, :string, "user discord id", required: true)
      featured_build_id(:body, :string, "build id. Must be owned by the user", required: true)
    end

    response(200, "OK", Schema.ref(:User))
  end
end
