defmodule MinimalServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :minimal_server,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MinimalServer.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.0"},
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 0.10", except: :prod, runtime: false},
      #      {:lowendinsight, path: "../lowendinsight"}
      {:lowendinsight, git: "https://bitbucket.org/kitplummer/lowendinsight", branch: "develop"}
    ]
  end
end
