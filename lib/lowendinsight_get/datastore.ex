# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Datastore do
  @moduledoc """
  In order to provide faster analysis, by caching repo reports LowEndInsight
  needs someplace to store the reports.  The current implementation is using
  Redis as the backend store and the redix Elixir library.
  """

  require Logger

  @doc """
  write_event/1: takes in a report and writes it as an event, incrementing the event
  counter.  Will return {:ok, id} - id being the current event counter on success, or
  {:error, reason} if there is an error writing to Redis.
  """
  def write_event(report) do
    case Redix.command(:redix, ["INCR", "event:id"]) do
      {:ok, id} ->
        Redix.command(:redix, ["SET", "event-#{id}", Poison.encode!(report)])
        Logger.debug("wrote event to redis -> #{Poison.encode!(report)}")
        {:ok, id}
      {:error, reason} ->
        Logger.error("no db available (#{reason}), processing -> #{Poison.encode!(report)}")
        {:error, reason}
    end
  end

  def write_job(uuid, report) do
    case Redix.command(:redix, ["SET", uuid, Poison.encode!(report)]) do
      {:ok, res} ->
        Logger.debug("wrote job #{uuid} -> #{Poison.encode!(report)}")
        {:ok, res}

      {:error, res} ->
        Logger.error("failed to write job #{uuid} -> #{Poison.encode!(report)}")
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

  @doc """
  write_to_cache/2: takes in a url as the key, and the analysis report as value
  and returns {:ok, res} on success, or {:error, res} on write error.
  """
  def write_to_cache(url, report) do
    case Redix.command(:redix, ["SET", url, Poison.encode!(report)]) do
      {:ok, res} ->
        Logger.debug("wrote report #{url} -> #{Poison.encode!(report)}")
        {:ok, res}

      {:error, res} ->
        Logger.error("failed to write report #{url} -> #{Poison.encode!(report)}: #{res}")
        {:error, res}
    end
  end

  @doc """
  get_from_cache/2: takes in a url and age in days, queries the datastore 
  and returns {:ok, report} if it exists, and {:not_found} if it does not,
  or {:error, message} if there was an issue reading from the datastore.
  """
  def get_from_cache(url, age) do
    ## NOTE: redix will return :ok even if key is not found, with
    ## the returned value as 'nil'
    case Redix.command(:redix, ["GET", url]) do
      {:ok, res} ->
        Logger.debug("get report #{url} -> #{res}")

        case res do
          nil ->
            {:error, "report not found"}

          _ ->
            r = Poison.decode!(res)

            case too_old?(r, age) do
              true -> {:error, "current report not found"}
              false -> {:ok, res}
            end
        end

      {:error, _res} ->
        Logger.debug("failed to get report -> #{url}")
        {:error, "failed to get report: #{url}"}
    end
  end

  @doc """
  too_old?/2: takes in a repo report and age in days and returns 'true' if the diff
  between the current datetime and the report end_time is greater than the 
  provided age - or return 'false'
  """
  def too_old?(repo, age) do
    days =
      TimeHelper.get_commit_delta(repo["header"]["end_time"])
      |> TimeHelper.sec_to_days()

    days > age
  end
end
