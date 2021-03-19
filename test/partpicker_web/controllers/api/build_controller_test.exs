defmodule PartpickerWeb.BuildControllerTest do
  use PartpickerWeb.ConnCase

  setup %{conn: conn} do
    {token, data} = Partpicker.Accounts.APIToken.build_api_token()
    _ = Partpicker.Repo.insert!(data)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, user} =
      Partpicker.Accounts.api_register_user(%{discord_user_id: System.unique_integer([:positive])})

    {:ok, build} = Partpicker.Builds.create_build(user)

    {:ok, [conn: conn, user: user, build: build]}
  end

  test "create new build", %{conn: conn, user: user} do
    conn = post(conn, Routes.user_build_path(conn, :create, user.discord_user_id), %{build: %{}})
    assert json_response(conn, 201)["uid"]
  end

  test "show a build", %{conn: conn, user: user, build: build} do
    conn = get(conn, Routes.user_build_path(conn, :show, user.discord_user_id, build.uid))
    assert json_response(conn, 200)["uid"] == build.uid
  end

  test "doesn't show a build based on it's DB id", %{conn: conn, user: user, build: build} do
    assert_error_sent 404, fn ->
      get(conn, Routes.user_build_path(conn, :show, user.discord_user_id, build.id))
    end

    assert_error_sent 404, fn ->
      get(conn, Routes.user_build_path(conn, :show, user.id, build.id))
    end

    assert_error_sent 404, fn ->
      get(conn, Routes.user_build_path(conn, :show, user.id, build.uid))
    end
  end

  test "update a build", %{conn: conn, user: user, build: build} do
    attrs = %{
      year: 1920,
      color: "Crystal White",
      description: "some info",
      wheels: "rpf1s",
      tires: "RS4s",
      vin: "123asdf"
    }

    conn =
      put(conn, Routes.user_build_path(conn, :update, user.discord_user_id, build.uid), %{
        build: attrs
      })

    assert json_response(conn, 202)["year"] == 1920
    assert json_response(conn, 202)["color"] == "Crystal White"
    assert json_response(conn, 202)["description"] == "some info"
    assert json_response(conn, 202)["wheels"] == "rpf1s"
    assert json_response(conn, 202)["tires"] == "RS4s"
    assert json_response(conn, 202)["vin"] == "123asdf"
  end

  test "upload build banner photo", %{conn: conn, user: user, build: build} do
    url =
      "https://cdn.discordapp.com/attachments/480812764059926550/821139299071295518/image0.jpg"

    conn =
      post(conn, Routes.user_build_build_path(conn, :banner, user.discord_user_id, build.uid), %{
        photo: %{attachment_url: url}
      })

    refute json_response(conn, 202)["banner_photo"]
  end
end
