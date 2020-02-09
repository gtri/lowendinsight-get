# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

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

    case Task.Supervisor.start_child(
           __MODULE__,
           LowendinsightGet.Analysis,
           :process,
           [uuid, urls, start_time],
           opts
         ) do
      {:ok, _pid} ->
        {:ok, "started analysis task for #{uuid}"}

      {:error, error} ->
        {:error, error}
    end
  end
end
