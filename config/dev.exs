# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

import Config

config :lowendinsight_get,
  check_repo_size?: String.to_atom(System.get_env("LEI_CHECK_REPO_SIZE") || "false"),
  gh_token: System.get_env("LEI_GH_TOKEN") || "",
  num_of_repos: String.to_integer(System.get_env("LEI_NUM_OF_REPOS") || "10"),
  wait_time: String.to_integer(System.get_env("LEI_WAIT_TIME") || "1800000")

config :redix,
  redis_url: System.get_env("REDIS_URL") || "redis://localhost:6379/3"
