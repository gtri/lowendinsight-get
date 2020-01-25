# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.AnalysisSupervisor do
  def perform_analysis(uuid, urls, start_time) do
    opts = [restart: :transient]
    case Task.Supervisor.start_child(__MODULE__, LowendinsightGet.Analysis, :process, [uuid, urls, start_time], opts) do
      {:ok, _pid} -> 
        {:ok, "started analysis task for #{uuid}"}
      {:error, error} -> {:error, error}
    end
  end
end
