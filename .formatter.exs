[
  surface_line_length: 120,
  import_deps: [:ecto, :phoenix, :surface],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  surface_inputs: ["{lib,test}/**/*.{ex,sface}"],
  subdirectories: ["priv/*/migrations"]
]
