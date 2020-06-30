# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.CacheCleaner do
  require Logger

  def clean() do
    cache_ttl = Application.get_env(:lowendinsight_get, :cache_ttl, 2_592_000)
    Logger.info("SCHEDULER: TTL -> #{cache_ttl}")
    {:ok, conn} = Redix.start_link(Application.get_env(:redix, :redis_url))

    case Redix.command(conn, ["KEYS", "http*"]) do
      {:ok, keys} ->
        Enum.each(keys, fn key ->
          Logger.debug("key -> #{key}")

          case Redix.command(conn, ["GET", key]) do
            {:ok, nil} ->
              Logger.debug("#{key}: already gone")
              {:ok, nil}
      
            {:ok, json} ->
              value = Poison.decode!(json)
              report_time = value["header"]["end_time"] |> TimeHelper.get_commit_delta()
              cache_ttl = Application.get_env(:lowendinsight_get, :cache_ttl) * 86400
      
              if report_time > cache_ttl do
                Redix.command(conn, ["DEL", key])
                Logger.info("Deleting TTL expired key: #{key}")
              end
          end
        end)
    end

    Redix.stop(conn)
  end
end
