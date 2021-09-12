require Logger
Logger.info("Seeding DB")

alias Partpicker.{
        Repo,
        Accounts,
        Builds
      },
      warn: false

{:ok, user1} =
  Accounts.oauth_discord_register_user(%{
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

{:ok, build1} = Builds.create_build(user1)

%Builds.FeaturedBuild{build_id: build1.id, user_id: user1.id}
|> Repo.insert!()

Ecto.Changeset.change(user1, %{prefered_unit: :miles})
|> Repo.update!()
|> Accounts.add_role(:admin)
|> Accounts.add_role(:library)

{:ok, user2} =
  Accounts.oauth_discord_register_user(%{
    "avatar" => "3d5654e70fd35668094636812cabc222",
    "discriminator" => "0690",
    "email" => "test@test.org",
    "flags" => 256,
    "id" => "363115894126147613",
    "locale" => "en-US",
    "mfa_enabled" => true,
    "premium_type" => 2,
    "public_flags" => 256,
    "username" => "seconduser",
    "verified" => true
  })

{:ok, build2} = Builds.create_build(user2)

%Builds.FeaturedBuild{build_id: build2.id, user_id: user2.id}
|> Repo.insert!()

Ecto.Changeset.change(user2, %{prefered_unit: :miles})
|> Repo.update!()
|> Accounts.add_role(:admin)
|> Accounts.add_role(:library)

{token, data} = Partpicker.Accounts.APIToken.build_api_token()
_ = Partpicker.Repo.insert!(data)
IO.inspect(token, label: "TOKEN")

for path <- Path.wildcard("assets/static/images/plates/*"),
    do: %Partpicker.TCG.PrintingPlate{filename: Path.basename(path)} |> Repo.insert!()

# plate1 = %Partpicker.TCG.PrintingPlate{filename: "cone-tcg.png"} |> Repo.insert!()
# plate2 = %Partpicker.TCG.PrintingPlate{filename: "haz-tcg.png"} |> Repo.insert!()

# {:ok, virtual1} = Partpicker.TCG.print_virtual(plate1, user1)
# {:ok, virtual2} = Partpicker.TCG.print_virtual(plate2, user2)

# {:ok, trade} = Partpicker.TCG.initiate_trade(virtual1, virtual2)
# {:ok, accepted} = Partpicker.TCG.accept_trade(trade)
# IO.inspect(accepted, label: "ACCEPTED TRADE")
