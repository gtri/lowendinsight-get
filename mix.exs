# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.MixProject do
  use Mix.Project

  def project do
    [
      app: :lowendinsight_get,
      version: "0.3.3",
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
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 0.10", except: :prod, runtime: false},
      {:redix, ">= 0.0.0"},
      ## {:lowendinsight, path: "../lowendinsight"},
      ## {:lowendinsight, git: "git@bitbucket.org:kitplummer/lowendinsight", branch: "develop"}
      {:lowendinsight, "0.4.0"},
      {:distillery, "~> 2.1"},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end
end
