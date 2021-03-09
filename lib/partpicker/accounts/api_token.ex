defmodule Partpicker.Accounts.APIToken do
  use Ecto.Schema
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 32

  @session_validity_in_days 365

  schema "api_tokens" do
    field :token, :binary
    field :context, :string
    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_api_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %Partpicker.Accounts.APIToken{
       token: hashed_token,
       context: "api"
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token.
  """
  def verify_api_token_query(token) do
    hashed_token = :crypto.hash(@hash_algorithm, Base.url_decode64!(token, padding: false))

    query =
      from token in token_and_context_query(hashed_token, "api"),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: token

    {:ok, query}
  end

  @doc """
  Returns the given token with the given context.
  """
  def token_and_context_query(token, context) do
    from Partpicker.Accounts.APIToken, where: [token: ^token, context: ^context]
  end
end
