defmodule LowendinsightGet.MixProject do
  use Mix.Project

  def project do
    [
      app: :lowendinsight_get,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {LowendinsightGet.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 0.10", except: :prod, runtime: false},
      {:redix, ">= 0.0.0"},
      ##{:lowendinsight, path: "../lowendinsight"}
      ##{:lowendinsight, git: "git@bitbucket.org:kitplummer/lowendinsight", branch: "develop"}
      {:lowendinsight, "0.2.3"},
      {:distillery, "~> 2.1"}
    ]
  end
end
