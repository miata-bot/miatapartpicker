defmodule PartpickerWeb.BuildLiveTest do
  use PartpickerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Partpicker.Builds

  @create_attrs %{color: "some color", year: 42}
  @update_attrs %{
    color: "some updated color",
    year: 43
  }
  @invalid_attrs %{color: 1, make: nil, model: nil, year: nil}

  defp fixture(user, :build) do
    {:ok, build} = Builds.create_build(@create_attrs)
    build
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      Partpicker.Accounts.register_user_with_oauth_discord(
        Enum.into(attrs, %{
          "id" => System.unique_integer([:positive]),
          "email" => nil
        })
      )

    user
  end

  defp create_build(context) do
    build = fixture(context.user, :build)
    %{build: build}
  end

  defp create_user(context) do
    user = user_fixture()
    %{context | user: user}
  end

  describe "Index" do
    setup [:create_user]
    setup [:create_build]

    test "lists all builds", %{conn: conn, build: build} do
      {:ok, _index_live, html} = live(conn, Routes.build_index_path(conn, :index))

      assert html =~ "Listing Builds"
      assert html =~ build.color
    end

    test "saves new build", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.build_index_path(conn, :index))

      assert index_live |> element("a", "New Build") |> render_click() =~
               "New Build"

      assert_patch(index_live, Routes.build_index_path(conn, :new))

      assert index_live
             |> form("#build-form", build: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#build-form", build: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.build_index_path(conn, :index))

      assert html =~ "Build created successfully"
      assert html =~ "some color"
    end

    test "updates build in listing", %{conn: conn, build: build} do
      {:ok, index_live, _html} = live(conn, Routes.build_index_path(conn, :index))

      assert index_live |> element("#build-#{build.id} a", "Edit") |> render_click() =~
               "Edit Build"

      assert_patch(index_live, Routes.build_index_path(conn, :edit, build))

      assert index_live
             |> form("#build-form", build: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#build-form", build: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.build_index_path(conn, :index))

      assert html =~ "Build updated successfully"
      assert html =~ "some updated color"
    end

    test "deletes build in listing", %{conn: conn, build: build} do
      {:ok, index_live, _html} = live(conn, Routes.build_index_path(conn, :index))

      assert index_live |> element("#build-#{build.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#build-#{build.id}")
    end
  end

  describe "Show" do
    setup [:create_build]

    test "displays build", %{conn: conn, build: build} do
      {:ok, _show_live, html} = live(conn, Routes.build_show_path(conn, :show, build))

      assert html =~ "Show Build"
      assert html =~ build.color
    end

    test "updates build within modal", %{conn: conn, build: build} do
      {:ok, show_live, _html} = live(conn, Routes.build_show_path(conn, :show, build))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Build"

      assert_patch(show_live, Routes.build_show_path(conn, :edit, build))

      assert show_live
             |> form("#build-form", build: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#build-form", build: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.build_show_path(conn, :show, build))

      assert html =~ "Build updated successfully"
      assert html =~ "some updated color"
    end
  end
end
