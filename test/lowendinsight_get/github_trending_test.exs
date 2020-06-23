# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.GithubTrendingTest do
  use ExUnit.Case, async: false

  test "it performs analysis on the trending repos in github" do
    {:ok, msg} = LowendinsightGet.GithubTrending.analyze("elixir")
    assert true == String.contains?(msg, "successfully")
    report = LowendinsightGet.GithubTrending.get_current_gh_trending_report("elixir")
    assert report["state"] == "complete" || "incomplete"
  end

  test "large repo filter" do
    check_repo? = LowendinsightGet.GithubTrending.check_repo_size?()
    # if Application.fetch_env(:lowendinsight_get, :check_repo_size?) == :error,
    # do: false,
    # else: Application.fetch_env!(:lowendinsight_get, :check_repo_size?)

    url = "https://github.com/torvalds/linux"

    {repo_size, url} = LowendinsightGet.GithubTrending.get_repo_size(url)
    new_url = LowendinsightGet.GithubTrending.filter_out_large_repos({repo_size, url}, check_repo?)
    assert new_url == "https://github.com/torvalds/linux-skip_too_big"
  end
end
