# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.CacheCleanerTest do
  use ExUnit.Case, async: false

  setup_all do
    Redix.command(:redix, ["FLUSHDB"])

    on_exit(fn ->
      Task.Supervisor.children(LowendinsightGet.AnalysisSupervisor)
      |> Enum.map(fn child ->
        Task.Supervisor.terminate_child(LowendinsightGet.AnalysisSupervisor, child)
      end)
    end)
  end

  @tag timeout: 180_000
  test "deletes key when cache TTL expires" do
    elixir_url = "https://github.com/elixir-lang/elixir"
    {:ok, _report} = LowendinsightGet.Analysis.analyze(elixir_url, "lei-get", %{types: false})
    {:ok, conn} = Redix.start_link(Application.get_env(:redix, :redis_url))

    assert {:ok, nil} == LowendinsightGet.CacheCleaner.check_ttl(conn, "fake_key")
    assert :deleted == LowendinsightGet.CacheCleaner.check_ttl(conn, elixir_url, true)

    Redix.stop(conn)
  end

  @tag timeout: 180_000
  test "it cleans" do
    elixir_url = "https://github.com/elixir-lang/elixir"
    {:ok, _report} = LowendinsightGet.Analysis.analyze(elixir_url, "lei-get", %{types: false})

    assert :ok == LowendinsightGet.CacheCleaner.clean()
  end
end
