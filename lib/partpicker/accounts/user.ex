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
    field :preferred_timezone, :string
    has_many :cards, Partpicker.TCG.VirtualCard
    has_many :trade_requests, Partpicker.TCG.TradeRequest, foreign_key: :sender_id

    field :roles, {:array, Ecto.Enum}, values: [:admin, :library], default: []

    # discord fields
    field :username, :string
    field :avatar, :string
    field :discriminator, :string

    # steam fields
    field :steam_id, :string

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
      :foot_size,
      :preferred_timezone
    ])
    |> validate_timezone()
    |> validate_required([:discord_user_id])
  end

  def settings_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :instagram_handle,
      :prefered_unit,
      :hand_size,
      :foot_size,
      :preferred_timezone
    ])
    |> validate_timezone()
    |> validate_required([])
  end

  def import_changeset(user, attrs) do
    user
    |> cast(attrs, [:discord_user_id, :instagram_handle])
    |> validate_required([:discord_user_id])
    |> unique_constraint(:discord_user_id)
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :discord_user_id, :username, :avatar, :discriminator])
    |> validate_required([:discord_user_id])
    |> unique_constraint(:discord_user_id)
  end

  def connections_changeset(user, connections) do
    attrs =
      Enum.find_value(connections, fn
        %{"type" => "steam", "id" => steam_id} -> %{"steam_id" => steam_id}
        _ -> false
      end)

    user
    |> cast(attrs || %{}, [:steam_id])
  end

  def validate_timezone(changeset) do
    if tz = get_change(changeset, :preferred_timezone) do
      if tz in Tzdata.zone_list() do
        changeset
      else
        add_error(changeset, :preferred_timezone, "Not a known timezone sorry")
      end
    else
      changeset
    end
  end
end
