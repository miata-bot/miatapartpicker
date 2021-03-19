require Logger

alias Partpicker.{
        Repo,
        Accounts,
        Builds
      },
      warn: false

{:ok, user} =
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

{:ok, build} = Builds.create_build(user)

%Builds.FeaturedBuild{build_id: build.id, user_id: user.id}
|> Repo.insert!()

user =
  Ecto.Changeset.change(user, %{admin: true, prefered_unit: :miles})
  |> Repo.update!()

{token, data} = Partpicker.Accounts.APIToken.build_api_token()
_ = Partpicker.Repo.insert!(data)

IO.inspect(token, label: "TOKEN")
