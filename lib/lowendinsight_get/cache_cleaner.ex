# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.CacheCleaner do
  require Logger

  def clean() do
    cache_ttl = Application.get_env(:lowendinsight_get, :cache_ttl, 2_592_000)
    Logger.info("TESTING SCHEDULER: TTL -> #{cache_ttl}")

    case Redix.command(:redix, ["KEYS", "http*"]) do
      {:ok, keys} ->
        Enum.each(keys, fn key ->
          Logger.debug("key -> #{key}")

          case Redix.command(:redix, ["GET", key]) do
            {:ok, nil} ->
              Logger.debug("#{key}: already gone")

            {:ok, json} ->
              value = Poison.decode!(json)
              report_time = value["header"]["end_time"] |> TimeHelper.get_commit_delta()

              if report_time > Application.get_env(:lowendinsight_get, :cache_ttl, 2_592_000) do
                Redix.command(:redix, ["DEL", key])
                Logger.debug("deleting key: #{key}")
              end
          end
        end)
    end
  end
end
