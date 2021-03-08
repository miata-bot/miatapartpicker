defmodule Partpicker.Builds do
  @moduledoc """
  The Builds context.
  """

  import Ecto.Query, warn: false
  alias Partpicker.Repo

  alias Partpicker.Builds.Build

  @doc """
  Returns the list of builds.

  ## Examples

      iex> list_builds()
      [%Build{}, ...]

  """
  def list_builds do
    Repo.all(Build)
  end

  @doc """
  Gets a single build.

  Raises `Ecto.NoResultsError` if the Build does not exist.

  ## Examples

      iex> get_build!(123)
      %Build{}

      iex> get_build!(456)
      ** (Ecto.NoResultsError)

  """
  def get_build!(id), do: Repo.get!(Build, id)

  @doc """
  Creates a build.

  ## Examples

      iex> create_build(%{field: value})
      {:ok, %Build{}}

      iex> create_build(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_build(attrs \\ %{}) do
    %Build{}
    |> Build.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a build.

  ## Examples

      iex> update_build(build, %{field: new_value})
      {:ok, %Build{}}

      iex> update_build(build, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_build(%Build{} = build, attrs) do
    build
    |> Build.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a build.

  ## Examples

      iex> delete_build(build)
      {:ok, %Build{}}

      iex> delete_build(build)
      {:error, %Ecto.Changeset{}}

  """
  def delete_build(%Build{} = build) do
    Repo.delete(build)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking build changes.

  ## Examples

      iex> change_build(build)
      %Ecto.Changeset{data: %Build{}}

  """
  def change_build(%Build{} = build, attrs \\ %{}) do
    Build.changeset(build, attrs)
  end

  alias Partpicker.Builds.{
    Part
  }

  def change_part_import(%Part.ImportJob{} = import_job, attrs \\ %{}) do
    Part.ImportJob.changeset(import_job, attrs)
  end
end
