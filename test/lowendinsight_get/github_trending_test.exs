# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.GithubTrendingTest do
  use ExUnit.Case, async: false

  test "it performs analysis on the trending repos in github" do
    {:ok, msg} = LowendinsightGet.GithubTrending.analyze("elixir")
    assert true == String.contains?(msg, "successfully")
  end
end
