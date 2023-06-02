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

  def show(conn, %{"id" => build_uid}) do
    build = Partpicker.Builds.get_build_by_uid!(build_uid)
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

  def delete(conn, %{"user_id" => discord_user_id, "id" => build_uid}) do
    user = Partpicker.Accounts.get_user_by_discord_id!(discord_user_id)
    build = Partpicker.Builds.get_build_by_uid!(user, build_uid)

    case Partpicker.Builds.delete_build(build) do
      {:ok, _build} ->
        conn
        |> send_resp(204, "")
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

  use PhoenixSwagger

  def swagger_definitions do
    %{
      Build:
        swagger_schema do
          title("Build object")
          description("contains info about a build")

          properties do
            description(:string, "user supplied info about a build")
            color(:string, "color")
            year(:integer, "year")
            make(:string, "vehicle make")
            model(:string, "vehicle model")
            tires(:string, "tire type or name")
            banner_photo_id(:string, "photo id for featured photo")
            coilovers(:string, "part name of coilovers")
            mileage(:integer, "number of miles")
            ride_height(:float, "ground clearance")
            uid(:string, "internal unique id used to reference this specific build")
            vin(:number, "vehicle id")
          end
        end,
      Builds:
        swagger_schema do
          title("Builds")
          type(:array)
          items(Schema.ref(:Build))
        end,
      BuildCreate:
        swagger_schema do
          title("Build create or update object")
          description("contains info about a build")

          properties do
            description(:string, "user supplied info about a build")
            color(:string, "color")
            year(:integer, "year")
            make(:string, "vehicle make")
            model(:string, "vehicle model")
            tires(:string, "tire type or name")
            banner_photo_id(:string, "photo id for featured photo")
            coilovers(:string, "part name of coilovers")
            mileage(:integer, "number of miles")
            ride_height(:float, "ground clearance")
            vin(:number, "vehicle id")
          end
        end
    }
  end

  swagger_path :index do
    tag("Builds")
    get("/api/users/:user_id/builds")
    security([%{Bearer: []}])
    description("list builds for a user")

    parameters do
      user_id(:path, :string, "discord id")
    end

    response(200, "OK", Schema.ref(:Builds))
  end

  swagger_path :show do
    tag("Builds")
    get("/api/users/:user_id/builds/:build_id")
    security([%{Bearer: []}])
    description("list builds for a user")

    parameters do
      user_id(:path, :string, "discord id")
      build_id(:path, :string, "build id")
    end

    response(200, "OK", Schema.ref(:Build))
  end

  swagger_path :delete do
    tag("Builds")
    PhoenixSwagger.Path.delete("/api/users/:user_id/builds/:build_id")
    security([%{Bearer: []}])
    description("delete a build")

    parameters do
      user_id(:path, :string, "discord id")
      build_id(:path, :string, "build id")
    end

    response(204, "OK")
  end

  swagger_path :create do
    tag("Builds")
    post("/api/users/:user_id/builds/")
    security([%{Bearer: []}])
    description("create a build")

    parameters do
      user_id(:path, :string, "discord id")
      build(:body, Schema.ref(:BuildCreate), "Build creation params")
    end

    response(200, "OK", Schema.ref(:Build))
  end

  swagger_path :update do
    tag("Builds")
    put("/api/users/:user_id/builds/:build_id")
    security([%{Bearer: []}])
    description("create a build")

    parameters do
      user_id(:path, :string, "discord id")
      build_id(:path, :string, "build id")
      build(:body, Schema.ref(:BuildCreate), "Build update params")
    end

    response(200, "OK", Schema.ref(:Build))
  end
end
