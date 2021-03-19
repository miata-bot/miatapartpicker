defmodule PartpickerWeb.UserControllerTest do
  use PartpickerWeb.ConnCase

  setup %{conn: conn} do
    {token, data} = Partpicker.Accounts.APIToken.build_api_token()
    _ = Partpicker.Repo.insert!(data)

    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, user} =
      Partpicker.Accounts.api_register_user(%{discord_user_id: System.unique_integer([:positive])})

    {:ok, [conn: conn, user: user]}
  end

  test "create user", %{conn: conn} do
    conn =
      post(
        conn,
        Routes.user_path(conn, :create, %{user: %{discord_user_id: 316_741_621_498_511_363}})
      )

    assert json_response(conn, 201)["discord_user_id"] == 316_741_621_498_511_363
  end

  test "update user", %{conn: conn, user: user} do
    conn =
      put(conn, Routes.user_path(conn, :update, user.discord_user_id), %{
        user: %{instagram_handle: "@pressy4pie"}
      })

    assert json_response(conn, 202)["instagram_handle"] == "@pressy4pie"
  end

  test "can't update user with no record", %{conn: conn, user: user} do
    # user.id != user.discord_user_id
    # real db ids should not make it into the world i guess?
    assert_error_sent 404, fn ->
      put(conn, Routes.user_path(conn, :update, user.id), %{
        user: %{instagram_handle: "@pressy4pie"}
      })
    end
  end

  test "show user", %{conn: conn, user: user} do
    conn = get(conn, Routes.user_path(conn, :show, user.discord_user_id))
    assert json_response(conn, 200)["discord_user_id"] == user.discord_user_id
  end

  describe "builds" do
    test "renders builds", %{conn: conn, user: user} do
      {:ok, build1} = Partpicker.Builds.create_build(user, %{})
      {:ok, build2} = Partpicker.Builds.create_build(user, %{})
      conn = get(conn, Routes.user_path(conn, :show, user.discord_user_id))
      builds = json_response(conn, 200)["builds"]
      assert is_list(builds)
      assert Enum.count(builds) == 2
      assert Enum.find(builds, fn rendered_build -> rendered_build["uid"] == build1.uid end)
      assert Enum.find(builds, fn rendered_build -> rendered_build["uid"] == build2.uid end)
    end

    test "renders featured build", %{conn: conn, user: user} do
      {:ok, build} = Partpicker.Builds.create_build(user, %{})
      _ = Partpicker.Builds.create_featured_build!(user, build)
      conn = get(conn, Routes.user_path(conn, :show, user.discord_user_id))
      featured_build = json_response(conn, 200)["featured_build"]
      assert featured_build["uid"] == build.uid
    end

    test "update featured build", %{conn: conn, user: user} do
      {:ok, build} = Partpicker.Builds.create_build(user, %{})

      conn =
        put(conn, Routes.user_user_path(conn, :featured_build, user.discord_user_id), %{
          featured_build_id: build.uid
        })

      featured_build = json_response(conn, 202)["featured_build"]
      assert featured_build["uid"] == build.uid
    end
  end
end
