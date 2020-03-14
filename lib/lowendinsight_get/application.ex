# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Application do
  use Application

  alias LowendinsightGet.Endpoint

  require Logger

  def start(_type, _args) do
    # import Supervisor.spec

    Supervisor.start_link(children(), opts())
  end

  defp children do
    Logger.info("REDIS_URL: #{Application.get_env(:redix, :redis_url)}")

    kids = [
      {Redix,
       {Application.get_env(:redix, :redis_url),
        [name: :redix, sync_connect: true, exit_on_disconnection: true]}},
      LowendinsightGet.Endpoint,
      {Task.Supervisor, name: LowendinsightGet.AnalysisSupervisor}
    ]

    kids =
      case Application.get_env(:lowendinsight_get, :cache_clean_enable) do
        true -> kids ++ [LowendinsightGet.Scheduler]
        false -> kids
      end

    kids
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: LowendinsightGet.Supervisor
    ]
  end
end
