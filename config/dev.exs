# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

use Mix.Config

config :redix,
  redis_url: System.get_env("REDIS_URL") || "redis://localhost:6379/3"