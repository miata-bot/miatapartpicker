defmodule Partpicker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:password, :hashed_password]}
  schema "users" do
    field :email, :string
    field :discord_user_id, Snowflake
    field :instagram_handle, :string
    field :prefered_unit, Ecto.Enum, values: [:km, :miles], default: :miles
    field :hand_size, :float
    field :foot_size, :float
    has_many :cards, Partpicker.TCG.VirtualCard
    has_many :trade_requests, Partpicker.TCG.TradeRequest, foreign_key: :sender_id

    field :roles, {:array, Ecto.Enum}, values: [:admin, :library], default: []

    embeds_one :discord_oauth_info, DiscordInfo, on_replace: :delete do
      field :username, :string
      field :avatar, :string
      field :discriminator, :string
    end

    has_many :builds, Partpicker.Builds.Build
    has_one :featured_build, Partpicker.Builds.FeaturedBuild
    timestamps()
  end

  def admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:instagram_handle, :prefered_unit, :hand_size, :foot_size, :roles])
  end

  def api_changeset(user, attrs) do
    user
    |> cast(attrs, [:instagram_handle, :prefered_unit])
  end

  def api_register_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :instagram_handle,
      :prefered_unit,
      :email,
      :discord_user_id,
      :prefered_unit,
      :hand_size,
      :foot_size
    ])
    |> validate_required([:discord_user_id])
  end

  def settings_changeset(user, attrs) do
    user
    |> cast(attrs, [:instagram_handle, :prefered_unit, :hand_size, :foot_size])
    |> validate_required([])
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
  end

  def import_changeset(user, attrs) do
    user
    |> cast(attrs, [:discord_user_id, :instagram_handle])
    |> validate_required([:discord_user_id])
    |> unique_constraint(:discord_user_id)
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :discord_user_id])
    |> validate_required([:discord_user_id])
    |> cast_embed(:discord_oauth_info, required: true, with: &child_changeset/2)
    |> unique_constraint(:discord_user_id)

    # |> validate_email()
  end

  def child_changeset(discord_oauth_info, attrs) do
    discord_oauth_info
    |> cast(attrs, [:username, :avatar, :discriminator])
    |> validate_required([])
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Partpicker.Repo)
    |> unique_constraint(:email)
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end
end
