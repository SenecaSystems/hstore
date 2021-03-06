Code.ensure_loaded?(Hex) and Hex.start

defmodule Geo.Mixfile do
  use Mix.Project

  def project do
    [ app: :hstore,
      version: "0.0.2",
      elixir: "~> 1.0.0",
      deps: deps,
      description: description,
      package: package,
      source_url: "https://github.com/senecasystems/hstore"    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  defp description do
    """
    A collection of encoders and decoders for hstore data type support for Postgrex.
    """
  end

  defp deps do
    [{:postgrex, "~> 0.6.0"},
     {:apex, "~>0.3.0"}]
  end

  defp package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      contributors: ["Chris Maddox"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/senecasystems/hstore",
        "Postgrex" => "https://github.com/ericmj/postgrex"
       }
    ]
  end
end
