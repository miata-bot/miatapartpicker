defmodule Partpicker.BuildsTest do
  use Partpicker.DataCase

  alias Partpicker.Builds

  describe "builds" do
    alias Partpicker.Builds.Build

    @valid_attrs %{color: "some color", make: "some make", model: "some model", year: 42}
    @update_attrs %{
      color: "some updated color",
      make: "some updated make",
      model: "some updated model",
      year: 43
    }
    @invalid_attrs %{color: 1, make: nil, model: nil, year: nil}

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

    def build_fixture(user, attrs \\ %{}) do
      {:ok, build} = Builds.create_build(user, Enum.into(attrs, @valid_attrs))
      build
    end

    setup do
      {:ok, %{user: user_fixture()}}
    end

    test "list_builds/0 returns all builds", %{user: user} do
      build = build_fixture(user)
      assert Enum.find(Builds.list_builds(user), &(&1.id == build.id))
    end

    test "get_build!/2 returns the build with given id", %{user: user} do
      build = build_fixture(user)
      assert Builds.get_build!(user, build.id).id == build.id
    end

    test "create_build/2 with valid data creates a build", %{user: user} do
      assert {:ok, %Build{} = build} = Builds.create_build(user, @valid_attrs)
      assert build.color == "some color"
      assert build.year == 42
    end

    test "create_build/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Builds.create_build(user, @invalid_attrs)
    end

    test "update_build/2 with valid data updates the build", %{user: user} do
      build = build_fixture(user)
      assert {:ok, %Build{} = build} = Builds.update_build(build, @update_attrs)
      assert build.color == "some updated color"
      assert build.year == 43
    end

    test "update_build/2 with invalid data returns error changeset", %{user: user} do
      build = build_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Builds.update_build(build, @invalid_attrs)
      assert Builds.get_build!(user, build.id).id == build.id
    end

    test "delete_build/1 deletes the build", %{user: user} do
      build = build_fixture(user)
      assert {:ok, %Build{}} = Builds.delete_build(build)
      assert_raise Ecto.NoResultsError, fn -> Builds.get_build!(user, build.id) end
    end

    test "change_build/1 returns a build changeset", %{user: user} do
      build = build_fixture(user)
      assert %Ecto.Changeset{} = Builds.change_build(build)
    end
  end
end
