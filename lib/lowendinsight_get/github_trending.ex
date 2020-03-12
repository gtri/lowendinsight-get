# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.GithubTrending do
  require Logger

  @type language() :: String.t()

  @spec analyze(language()) :: :ok
  def analyze(language) do
    Logger.info("Github Trending Analysis: {#{language}}")
    uuid = UUID.uuid1()
    case fetch_trending_list(language) do
      {:error, reason} ->
        {:error, reason}

      {:ok, list} ->
        urls = filter_to_urls(list)

        LowendinsightGet.Analysis.process_urls(
          urls,
          uuid,
          DateTime.utc_now()
        )
        #Write the UUID into the gh_trending entry in Redis
        Redix.command(:redix, ["SET", "gh_trending_uuid", uuid])
        {:ok, "successfully analyzed trending repos for job id:#{uuid}"}
    end


  end

  def get_current_gh_trending_report() do
    {:ok, uuid} = Redix.command(:redix, ["GET", "gh_trending_uuid"])
    {:ok, report_json} = Redix.command(:redix, ["GET", uuid])
    Poison.Parser.parse!(report_json)

  end

  defp filter_to_urls(list) do
    for repo <- list, do: repo["url"]
  end

  defp fetch_trending_list(language) do
    url = "https://github-trending-api.now.sh\?language\=#{language}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Poison.Parser.parse!(body)}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not found :("}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
