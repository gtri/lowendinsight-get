# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

use Mix.Config

config :lowendinsight_get, LowendinsightGet.Endpoint, port: String.to_integer(System.get_env("PORT") || "4444")
## Default Cache TTL is 30 days or 25920000 seconds
config :lowendinsight_get,
  cache_ttl: String.to_integer(System.get_env("LEI_CACHE_TTL") || "30"),
  cache_clean_enable: String.to_atom(System.get_env("LEI_CACHE_CLEAN_ENABLE") || "true"),
  check_repo_size?: String.to_atom(System.get_env("LEI_CHECK_REPO_SIZE") || "true"),
  wait_time: String.to_integer(System.get_env("LEI_WAIT_TIME") || "7200000"),
  num_of_repos: String.to_integer(System.get_env("LEI_NUM_OF_REPOS") || "5"),
  gh_token: System.get_env("LEI_GH_TOKEN") || ""
  languages: [
    "elixir",
    "python",
    "go",
    "rust",
    "java",
    "javascript",
    "ruby",
    "c",
    "c++",
    "c#",
    "haskell",
    "php",
    "scala",
    "swift",
    "objective-c",
    "kotlin",
    "shell",
    "typescript"
  ]

config :lowendinsight,
  ## Contributor in terms of discrete users
  ## NOTE: this currently doesn't discern same user with different email
  critical_contributor_level: String.to_integer(System.get_env("LEI_CRITICAL_CONTRIBUTOR_LEVEL") || "2"),
  high_contributor_level: System.get_env("LEI_HIGH_CONTRIBUTOR_LEVEL") || 3,
  medium_contributor_level: System.get_env("LEI_CRITICAL_CONTRIBUTOR_LEVEL") || 5,

  ## Commit currency in weeks - is the project active.  This by itself
  ## may not indicate anything other than the repo is stable. The reason
  ## we're reporting it is relative to the likelihood vulnerabilities
  ## getting fix in a timely manner
  critical_currency_level: String.to_integer(System.get_env("LEI_CRITICAL_CURRENCY_LEVEL") || "104"),
  high_currency_level: String.to_integer(System.get_env("LEI_HIGH_CURRENCY_LEVEL") || "52"),
  medium_currency_level: String.to_integer(System.get_env("LEI_MEDIUM_CURRENCY_LEVEL") || "26"),

  ## Percentage of changes to repo in recent commit - is the codebase
  ## volatile in terms of quantity of source being changed
  critical_large_commit_level: String.to_float(System.get_env("LEI_CRITICAL_LARGE_COMMIT_LEVEL") || "0.30"),
  high_large_commit_level: String.to_float(System.get_env("LEI_HIGH_LARGE_COMMIT_LEVEL") || "0.15"),
  medium_large_commit_level: String.to_float(System.get_env("LEI_MEDIUM_LARGE_COMMIT_LEVEL") || "0.05"),

  ## Bell curve contributions - if there are 30 contributors
  ## but 90% of the contributions are from 2...
  critical_functional_contributors_level: String.to_integer(System.get_env("LEI_CRITICAL_FUNCTIONAL_CONTRIBUTORS_LEVEL") || "2"),
  high_functional_contributors_level: String.to_integer(System.get_env("LEI_HIGH_FUNCTIONAL_CONTRIBUTORS_LEVEL") || "3"),
  medium_functional_contributors_level: String.to_integer(System.get_env("LEI_MEDIUM_FUNCTIONAL_CONTRIBUTORS_LEVEL") || "5"),

  ## Jobs per available core for defining max concurrency.  This value
  ## will be used to set the max_concurrency value.
  jobs_per_core_max: String.to_integer(System.get_env("LEI_JOBS_PER_CORE_MAX") || "2"),

  ## Base directory structure for temp clones
  base_temp_dir: System.get_env("LEI_BASE_TEMP_DIR") || "/tmp"

config :redix,
  redis_url: System.get_env("REDIS_URL")

config :lowendinsight_get, LowendinsightGet.Scheduler,
jobs: [
  # Every 5 minutes
  {"*/5 * * * *", {LowendinsightGet.CacheCleaner, :clean, []}},
  {"0 0 * * *", {LowendinsightGet.GithubTrending, :analyze, []}}
]
