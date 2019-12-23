use Mix.Config

config :minimal_server, MinimalServer.Endpoint, port: 4000

import_config "#{Mix.env()}.exs"

config :lowendinsight,
  access_token: "2985bf2c1ff4b41863aef325b2ed527a120b6bc0",
  critical_contributor_level: 2,
  high_contributor_level: 3,
  medium_contributor_level: 5,
  critical_currency_level: 104,  # in weeks
  high_currency_level: 52,
  medium_currency_level: 26,
  high_large_commit_level: 0.30,
  medium_large_commit_level: 0.15,
  low_large_commit_level: 0.05,
  critical_functional_contributors_level: 2,
  high_functional_contributors_level: 4,
  medium_functional_contributors_level: 5,
  functional_contributors_filter_percent: 0.10

# config :redix,
#   server: "localhost",
#   port: 6379,
#   db: 3
