defmodule Partpicker.Library do
  @moduledoc """
  The Library context.
  """

  import Ecto.Query, warn: false
  alias Partpicker.Repo

  alias Partpicker.Library.Connector

  @doc """
  Returns the list of connectors.

  ## Examples

      iex> list_connectors()
      [%Connector{}, ...]

  """
  def list_connectors do
    Repo.all(from c in Connector, order_by: {:asc, :name})
  end

  @doc """
  Gets a single connector.

  Raises `Ecto.NoResultsError` if the Connector does not exist.

  ## Examples

      iex> get_connector!(123)
      %Connector{}

      iex> get_connector!(456)
      ** (Ecto.NoResultsError)

  """
  def get_connector!(id), do: Repo.get!(Connector, id)

  @doc """
  Creates a connector.

  ## Examples

      iex> create_connector(%{field: value})
      {:ok, %Connector{}}

      iex> create_connector(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_connector(attrs \\ %{}) do
    %Connector{}
    |> Connector.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a connector.

  ## Examples

      iex> update_connector(connector, %{field: new_value})
      {:ok, %Connector{}}

      iex> update_connector(connector, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_connector(%Connector{} = connector, attrs) do
    connector
    |> Connector.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a connector.

  ## Examples

      iex> delete_connector(connector)
      {:ok, %Connector{}}

      iex> delete_connector(connector)
      {:error, %Ecto.Changeset{}}

  """
  def delete_connector(%Connector{} = connector) do
    Repo.delete(connector)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking connector changes.

  ## Examples

      iex> change_connector(connector)
      %Ecto.Changeset{data: %Connector{}}

  """
  def change_connector(%Connector{} = connector, attrs \\ %{}) do
    Connector.changeset(connector, attrs)
  end
end
