# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.CacheCleanerTest do
  use ExUnit.Case, async: false

  setup_all do
    :ok
  end

  test "it cleans" do
    assert :ok == LowendinsightGet.CacheCleaner.clean()

  end


end
