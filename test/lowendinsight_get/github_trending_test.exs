# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.GithubTrendingTest do
  use ExUnit.Case, async: false

  test "it performs analysis on the trending repos in github" do
    case LowendinsightGet.GithubTrending.analyze("elixir") do
      {:ok, msg} ->
        assert true == String.contains?(msg, "successfully")
        report = LowendinsightGet.GithubTrending.get_current_gh_trending_report("elixir")
        assert report["state"] == "complete" || "incomplete"
      {:error, msg} ->
        IO.inspect msg, label: "msg"
      end
  end

  test "large repo filter" do
    url = "https://github.com/torvalds/linux"
    {repo_size, url} = LowendinsightGet.GithubTrending.get_repo_size(url)
    check_repo? = LowendinsightGet.GithubTrending.check_repo_size?()

    new_url = LowendinsightGet.GithubTrending.filter_out_large_repos({repo_size, url}, check_repo?)

    if check_repo? == "true",
      do: assert new_url == "https://github.com/torvalds/linux-skip_too_big",
      else: assert new_url == "https://github.com/torvalds/linux"
  end

  test "gets wait time" do
    wait_time = Application.fetch_env!(:lowendinsight_get, :wait_time)
    assert wait_time == LowendinsightGet.GithubTrending.get_wait_time()
  end
end
