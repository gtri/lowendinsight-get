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

  test "redix get key" do
    elixir_url = "https://github.com/elixir-lang/elixir"
    {:ok, _report} = LowendinsightGet.Analysis.analyze(elixir_url, "lei-get", %{types: false})
    {:ok, conn} = Redix.start_link(Application.get_env(:redix, :redis_url))
    case Redix.command(conn, ["KEYS", "http*"]) do
      {:ok, _keys} ->
        assert {:ok, nil} == Redix.command(conn, ["GET", "fake_key"])
        case Redix.command(conn, ["GET", elixir_url]) do
          {:ok, json} ->
            value = Poison.decode!(json)
            assert value["header"]["end_time"] != nil
        end
    end
    Redix.stop(conn)
  end

  test "it cleans" do
    assert :ok == LowendinsightGet.CacheCleaner.clean()
  end
end
