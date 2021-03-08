require Logger

alias Partpicker.{
        Repo,
        Accounts
      },
      warn: false

{:ok, _user} =
  Accounts.register_user_with_oauth_discord(%{
    "avatar" => "3d5654e70fd35668094636812cabc222",
    "discriminator" => "0690",
    "email" => "konnorrigby@gmail.com",
    "flags" => 256,
    "id" => "316741621498511363",
    "locale" => "en-US",
    "mfa_enabled" => true,
    "premium_type" => 2,
    "public_flags" => 256,
    "username" => "PressY4Pie",
    "verified" => true
  })
