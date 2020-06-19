# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Analysis do
  require Logger

  def analyze(url, source, options) do
    LowendinsightGet.CounterAgent.add(self(), url)

    case LowendinsightGet.Datastore.get_from_cache(
           url,
           Application.get_env(:lowendinsight_get, :cache_ttl)
         ) do
      {:ok, repo_report} ->
        Logger.info("#{url} is cached, yay!")
        # have it in the cache, yay
        repo_data = Poison.decode!(repo_report, as: %RepoReport{data: %Data{results: %Results{}}})
        {:ok, repo_data}

      {:error, msg} ->
        Logger.info("No cache: #{msg}")
        # don't have it
        {:ok, rep} = AnalyzerModule.analyze(url, source, options)
        LowendinsightGet.Datastore.write_to_cache(url, rep)
        {:ok, rep}
    end
  end

  def process(uuid, urls, start_time) do
    Logger.info("processing #{uuid} -> #{urls}")
    {:ok, _counter} = LowendinsightGet.CounterAgent.new_counter(Enum.count(urls))
  
    repos =
      urls
      |> Task.async_stream(__MODULE__, :analyze, ["lei-get", %{types: false}],
          timeout: :infinity,
          max_concurrency: 1)
      |> Enum.map(fn {:ok, report} -> elem(report, 1) end)
    
    LowendinsightGet.CounterAgent.update_and_stop()
      
    report = %{
      state: "complete",
      report: %{uuid: UUID.uuid1(), repos: repos},
      metadata: %{repo_count: length(repos)}
    }

    report = AnalyzerModule.determine_risk_counts(report)

    end_time = DateTime.utc_now()
    duration = DateTime.diff(end_time, start_time)

    times = %{
      start_time: DateTime.to_iso8601(start_time),
      end_time: DateTime.to_iso8601(end_time),
      duration: duration
    }

    metadata = Map.put_new(report[:metadata], :times, times)
    report = report |> Map.put(:metadata, metadata)

    report = report |> Map.put(:uuid, uuid)
    ## We're finished with all the analysis work, write the report to datastore
    LowendinsightGet.Datastore.write_job(uuid, report)
    {:ok, report}
  end

  # Pulled into a function so it can be called for other interaces
  # Besides the endpoint.  Probably _should_ be in the analysis module.
  # TODO: move to analysis module, get the biz logic isolated
  def process_urls(urls, uuid, start_time) do
    if :ok == Helpers.validate_urls(urls) do
      Logger.debug("started #{uuid} at #{start_time}")

      ## Get empty report for new job to respond the request with
      empty = AnalyzerModule.create_empty_report(uuid, urls, start_time)
      LowendinsightGet.Datastore.write_job(uuid, empty)

      case LowendinsightGet.AnalysisSupervisor.perform_analysis(uuid, urls, start_time) do
        {:ok, task} ->
          Logger.info(task)
          {:ok, Poison.encode!(empty)}

        {:error, error} ->
          {:error, error}
      end
    else
      {:error, "invalid URLs list"}
    end
  end
end
