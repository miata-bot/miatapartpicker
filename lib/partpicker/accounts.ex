defmodule Partpicker.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Partpicker.Repo
  alias Partpicker.Accounts.{User, UserToken}

  def search_users(search_phrase) do
    start_character = String.slice(search_phrase, 0..1)

    from(
      u in User,
      where: ilike(u.username, ^"#{start_character}%"),
      where: fragment("SIMILARITY(?, ?) > 0", u.username, ^search_phrase),
      order_by: fragment("LEVENSHTEIN(?, ?)", u.username, ^search_phrase)
    )
    |> Repo.all()
  end

  ## Database getters

  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_discord_id(discord_id) do
    Repo.get_by(User, discord_user_id: discord_id)
  end

  def get_user_by_discord_id!(discord_id) do
    Repo.one!(from u in User, where: u.discord_user_id == ^discord_id)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def oauth_discord_register_user(%{"id" => discord_user_id, "email" => email} = me) do
    %User{}
    |> User.oauth_registration_changeset(%{
      discord_user_id: discord_user_id,
      email: email,
      username: me["username"],
      avatar: me["avatar"],
      discriminator: me["discriminator"]
    })
    |> Repo.insert()
  end

  def api_register_user(attrs \\ %{}) do
    %User{}
    |> User.api_register_changeset(attrs)
    |> Repo.insert()
  end

  def update_discord_oauth_info(user, me) do
    user
    |> User.oauth_registration_changeset(me)
    |> Repo.update()
  end

  ## Settings

  def change_settings(user, attrs \\ %{}) do
    User.settings_changeset(user, attrs)
  end

  def update_settings(user, attrs \\ %{}) do
    User.settings_changeset(user, attrs)
    |> Repo.update()
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)

    Repo.one(query)
    |> Repo.preload(:featured_build)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  def api_change_user(user, attrs) do
    User.api_changeset(user, attrs)
    |> Repo.update()
  end

  @valid_roles Ecto.Enum.values(User, :roles)

  def add_role(%{roles: roles} = user, role) when role in @valid_roles do
    if role not in roles do
      Ecto.Changeset.cast(user, %{roles: [role | roles]}, [:roles])
      |> Repo.update!()
    else
      user
    end
  end

  def delete_user(user) do
    Repo.delete(user)
  end

  def change_user(user, attrs \\ %{}) do
    user
    |> User.admin_changeset(attrs)
  end

  def update_user(user, attrs) do
    user
    |> change_user(attrs)
    |> Repo.update()
  end

  def migrate do
    {:ok, %{rows: rows}} = Repo.query("SELECT id,discord_oauth_info from users")

    Enum.map(rows, fn [id, oauth_info] ->
      get_user!(id)
      |> User.oauth_registration_changeset(oauth_info || %{})
      |> Repo.update!()
    end)
  end
end
