# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.
require Logger
defmodule LowendinsightGet.AnalysisSupervisor do
  @moduledoc """
  AnalysisSupervisor manages the asynchronous processing of incoming requests,
  farming out the work to sub-processes to perform the actual analysis.
  """

  @doc """
  perform_analysis/3: takes in a job uuid, array of urls and the analysis start_time
  and creates a new process to run the LowEndInsight analysis.

  TODO: what to do if the process bonks?  need to track and restart job if process
  fails at any point, in a hard-way (not just an input error or handled error.)
  """
  def perform_analysis(uuid, urls, start_time) do
    opts = [restart: :transient]
    ## Queue the analysis in the worker's exq config
    ## Only if use_workers is true
    if (Application.get_env(:lowendinsight_get, :use_workers)) do
      for url <- urls do
        Logger.debug("queueing up #{url}")
        case Exq.enqueue(Exq, "lei", LowendinsightWorker.Worker, [url]) do
          {:ok, ack} ->
            Logger.debug("ACKED from EXQ: #{ack}")
          {:error, msg} ->
            Logger.error(msg)
            raise RuntimeError, message: "Failed to queue the analysis job."
        end
      end
    else
      try do
        task = Task.Supervisor.async(__MODULE__, LowendinsightGet.Analysis, :process, [uuid, urls, start_time], opts)
        Task.await(task, LowendinsightGet.GithubTrending.get_wait_time())
      catch
        :exit, _ -> raise RuntimeError, message: "Timed out processing local async job."
      end
    end
    {:ok, "collected analysis for cached repos, queued work for new repos - on job: #{uuid}"}
  end
end
