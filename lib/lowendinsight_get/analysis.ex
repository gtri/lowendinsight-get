# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Analysis do
  require Logger
  def process(uuid, urls, start_time) do
    # TODO: process each url individually after checking to see if there is
    # a fresh entry in the cache
     
    Logger.info("processing #{uuid} -> #{urls}")
    response = AnalyzerModule.analyze urls, "lei-get", start_time
    case response do
      {:ok, rep} ->
        LowendinsightGet.Datastore.write_job(uuid, rep)
        {:ok, rep}
      {:error, rep} ->
        LowendinsightGet.Datastore.write_job(uuid, rep)
        {:error, rep}
    end
  end
end