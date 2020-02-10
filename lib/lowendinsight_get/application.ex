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
    #Logger.info("REDIS_HOST: #{Application.get_env(:redix, :server)}")
    #Logger.info("REDIS_PORT: #{Application.get_env(:redix, :port)}")

    [
      {Redix,
        {Application.get_env(:redix, :redis_url),
      #  host: Application.get_env(:redix, :server),
      #  port: Application.get_env(:redix, :port),
      #  sync_connect: true,
      #  exit_on_disconnection: true,
        [name: :redix]}},
      Endpoint,
      {Task.Supervisor, name: LowendinsightGet.AnalysisSupervisor}
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: LowendinsightGet.Supervisor
    ]
  end
end
