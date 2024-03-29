# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Analysis do
  require Logger

  def analyze(url, source, options) do
    if Process.whereis(:counter) do
      LowendinsightGet.CounterAgent.add(self(), url)
    end

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
    Logger.info("processing #{uuid} -> #{inspect urls}")
    LowendinsightGet.CounterAgent.new_counter(Enum.count(urls))

    repos =
      urls
      |> Task.async_stream(__MODULE__, :analyze, ["lei-get", %{types: false}],
          timeout: :infinity,
          max_concurrency: 1)
      |> Enum.map(fn {:ok, report} -> elem(report, 1) end)

    LowendinsightGet.CounterAgent.update()

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

  # Pulled into a function so it can be called for other interfaces
  # besides the endpoint.  Probably _should_ be in the analysis module.
  def process_urls(urls, uuid, start_time) do
    if :ok == Helpers.validate_urls(urls) do
      Logger.debug("started #{uuid} at #{start_time}")

      ## Get empty report for new job to respond the request with
      empty = AnalyzerModule.create_empty_report(uuid, urls, start_time)

      ## TODO: Populate empty with results from cache (within 30 days)
      repos =
        urls
        |> Enum.map(fn url ->
          case LowendinsightGet.Datastore.get_from_cache(url, 28) do
            {:ok, report} ->
              Poison.decode!(report)
            {:error, msg} ->
              Logger.debug(msg)
              # No cached create stub
              %{data: %{repo: url}}
          end
        end)

      # Update URL list
      urls =
        urls
        |> Enum.filter(fn url ->
          !LowendinsightGet.Datastore.in_cache?(url) end)
        |> Enum.map(fn url -> url end)

      # Update the state if we don't need to do any analysis, or do it
      # TODO: this is ugly!!  refactor after writing a test
      if length(urls) == 0 do
        metadata = empty[:metadata]
        times = metadata[:times]
        end_time = DateTime.utc_now()
        times = Map.replace!(times, :end_time, end_time)
        metadata = Map.replace!(metadata, :times, times)
        updated_report = Map.replace!(empty, :metadata, metadata)
        updated_report = Map.replace!(updated_report, :state, "complete")
        final_report = Map.replace!(updated_report, :report, %{:repos => repos})
        LowendinsightGet.Datastore.write_job(uuid, final_report)
        {:ok, Poison.encode!(final_report)}
      else
        partial_report = Map.replace!(empty, :report, %{:repos => repos})
        LowendinsightGet.Datastore.write_job(uuid, partial_report)
        case LowendinsightGet.AnalysisSupervisor.perform_analysis(uuid, urls, start_time) do
          {:ok, task} ->
            Logger.info(task)
            {:ok, Poison.encode!(partial_report)}

          {:error, error} ->
            {:error, error}
        end
      end
    else
      {:error, "invalid URLs list"}
    end
  end

  def refresh_job(job) do
    uuid = job["uuid"]
    repos = job["report"]["repos"]
    urls =
      repos
      |> Enum.reduce([], fn object, acc ->
        repo = object["data"]["repo"]
        if !Map.has_key?(object["data"], "results") do
          [ repo | acc ]
        else
          acc
        end
      end)
    ## TODO: Populate empty with results from cache (within 30 days)
    repos =
      urls
      |> Enum.map(fn url ->
        case LowendinsightGet.Datastore.get_from_cache(url, 28) do
          {:ok, report} ->
            Poison.decode!(report)
          {:error, msg} ->
            Logger.debug(msg)
            # No cached create stub
            %{data: %{repo: url}}
        end
      end)

    # Update URL list
    urls =
      urls
      |> Enum.filter(fn url ->
        !LowendinsightGet.Datastore.in_cache?(url) end)
      |> Enum.map(fn url -> url end)

    if length(urls) == 0 do
      metadata = job["metadata"]
      times = metadata["times"]
      end_time = DateTime.utc_now()
      times = Map.replace!(times, "end_time", end_time)
      metadata = Map.replace!(metadata, "times", times)
      updated_report = Map.replace!(job, "metadata", metadata)
      updated_report = Map.replace!(updated_report, "state", "complete")
      final_report = Map.replace!(updated_report, "report", %{:repos => repos})
      LowendinsightGet.Datastore.write_job(uuid, final_report)
      final_report
    else
      partial_report = Map.replace!(job, "report", %{:repos => repos})
      LowendinsightGet.Datastore.write_job(uuid, partial_report)
      case LowendinsightGet.AnalysisSupervisor.perform_analysis(uuid, urls, job["metadata"]["times"]["start_time"]) do
        {:ok, task} ->
          Logger.info(task)
          partial_report
        {:error, error} ->
          {:error, error}
      end
    end

  end
end
