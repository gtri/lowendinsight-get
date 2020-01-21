# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Datastore do

  require Logger

  def write_event(report) do
    case Redix.command(:redix, ["INCR", "event:id"]) do
      {:ok, id} ->
        Redix.command(:redix, ["SET", "event-#{id}", JSON.encode!(report)])
        Logger.debug("wrote event to redis -> #{JSON.encode!(report)}")
      {:error, reason} -> Logger.error("no db available (#{reason}), processing -> #{JSON.encode!(report)}")
    end
  end

  def write_job(uuid, report) do
    case Redix.command(:redix, ["SET", uuid, JSON.encode!(report)]) do
      {:ok, res} -> 
        Logger.debug("wrote job #{uuid} -> #{JSON.encode!(report)}")
        {:ok, res}
      {:error, res} -> 
        Logger.error("failed to write job #{uuid} -> #{JSON.encode!(report)}")
        {:error, res}
    end
  end

  def get_job(uuid) do
    ## NOTE: redix will return :ok even if key is not found, with
    ## the returned value as 'nil'
    case Redix.command(:redix, ["GET", uuid]) do
      {:ok, res} ->
        Logger.debug("get job #{uuid} -> #{res}")
        case res do
          nil -> {:error, "job not found"}
          _ -> {:ok, res}
        end
      {:error, _res} ->
        Logger.debug("failed to get job -> #{uuid}")
        {:error, "failed to get job: #{uuid}"}
    end
  end
end