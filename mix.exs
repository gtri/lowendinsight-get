# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.MixProject do
  use Mix.Project

  def project do
    [
      app: :lowendinsight_get,
      version: "0.7.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
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
      {:cowboy, "< 2.8.0", overide: true},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.5", except: :prod, runtime: false},
      {:redix, ">= 0.0.0"},
      {:quantum, "~> 3.0-rc"},
      {:timex, "~> 3.0"},
      ## {:lowendinsight, path: "../lowendinsight"},
      ## {:lowendinsight, git: "git@bitbucket.org:gtri/lowendinsight", branch: "develop"}
      {:lowendinsight, "0.7.0"},
      {:httpoison_retry, "~> 1.1.0"},
      {:distillery, "~> 2.1"},
      {:excoveralls, "~> 0.15", only: :test}
    ]
  end
end
