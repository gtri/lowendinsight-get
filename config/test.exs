# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

use Mix.Config

config :lowendinsight_get, LowendinsightGet.Endpoint,
  port: String.to_integer(System.get_env("PORT") || "4444")

config :lowendinsight,
  access_token: "2985bf2c1ff4b41863aef325b2ed527a120b6bc0",
  critical_contributor_par_level: 2,
  high_contributor_par_level: 3,
  medium_contributor_par_level: 5,
  critical_currency_par_level: 104,  # in weeks
  high_currency_par_level: 52,
  medium_currency_par_level: 26,
  high_large_commit_risk: 0.30,
  medium_large_commit_risk: 0.15,
  low_large_commit_risk: 0.05,
  high_functional_contributors_risk: 2,
  medium_functional_contributors_risk: 4,
  low_functional_contributors_risk: 5,
  functional_contributors_filter_percent: 0.10

config :redix,
  server: System.get_env("REDIS_HOST") || "localhost",
  port: String.to_integer(System.get_env("REDIS_PORT") || "6379"),
  db: 3
 