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
    @invalid_attrs %{color: nil, make: nil, model: nil, year: nil}

    def build_fixture(attrs \\ %{}) do
      {:ok, build} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Builds.create_build()

      build
    end

    test "list_builds/0 returns all builds" do
      build = build_fixture()
      assert Builds.list_builds() == [build]
    end

    test "get_build!/1 returns the build with given id" do
      build = build_fixture()
      assert Builds.get_build!(build.id) == build
    end

    test "create_build/1 with valid data creates a build" do
      assert {:ok, %Build{} = build} = Builds.create_build(@valid_attrs)
      assert build.color == "some color"
      assert build.make == "some make"
      assert build.model == "some model"
      assert build.year == 42
    end

    test "create_build/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Builds.create_build(@invalid_attrs)
    end

    test "update_build/2 with valid data updates the build" do
      build = build_fixture()
      assert {:ok, %Build{} = build} = Builds.update_build(build, @update_attrs)
      assert build.color == "some updated color"
      assert build.make == "some updated make"
      assert build.model == "some updated model"
      assert build.year == 43
    end

    test "update_build/2 with invalid data returns error changeset" do
      build = build_fixture()
      assert {:error, %Ecto.Changeset{}} = Builds.update_build(build, @invalid_attrs)
      assert build == Builds.get_build!(build.id)
    end

    test "delete_build/1 deletes the build" do
      build = build_fixture()
      assert {:ok, %Build{}} = Builds.delete_build(build)
      assert_raise Ecto.NoResultsError, fn -> Builds.get_build!(build.id) end
    end

    test "change_build/1 returns a build changeset" do
      build = build_fixture()
      assert %Ecto.Changeset{} = Builds.change_build(build)
    end
  end
end
