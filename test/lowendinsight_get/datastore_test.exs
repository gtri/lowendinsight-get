# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.DatastoreTest do
  use ExUnit.Case, async: false

  setup_all do
    report = %{
      data: %{
        config: %{
          critical_contributor_level: 2,
          critical_currency_level: 104,
          critical_functional_contributors_level: 2,
          critical_large_commit_level: 0.3,
          high_contributor_level: 3,
          high_currency_level: 52,
          high_functional_contributors_level: 3,
          high_large_commit_level: 0.15,
          medium_contributor_level: 5,
          medium_currency_level: 26,
          medium_functional_contributors_level: 5,
          medium_large_commit_level: 0.05
        },
        repo: "https://github.com/kitplummer/xmpp4rails",
        results: %{
          commit_currency_risk: "critical",
          commit_currency_weeks: 577,
          contributor_count: 1,
          contributor_risk: "critical",
          functional_contributor_names: ["Kit Plummer"],
          functional_contributors: 1,
          functional_contributors_risk: "critical",
          large_recent_commit_risk: "low",
          recent_commit_size_in_percent_of_codebase: 0.003683241252302026,
          top10_contributors: [%{"Kit Plummer" => 7}]
        },
        risk: "critical"
      },
      header: %{
        duration: 1,
        end_time: "2020-02-05T02:46:52.395737Z",
        library_version: "",
        source_client: "iex",
        start_time: "2020-02-05T02:46:51.375149Z",
        uuid: "c3996b38-47c1-11ea-97ea-88e9fe666193"
      }
    }

    [report: report]
  end

  test "it writes event", %{report: report} do
    case Redix.command(:redix, ["GET", "event:id"]) do
      {:ok, nil} -> 
        {:ok, id} = LowendinsightGet.Datastore.write_event(report)
        assert 1 == id
      {:ok, curr_id} ->
        {:ok, id} = LowendinsightGet.Datastore.write_event(report)
        assert String.to_integer(curr_id) + 1 == id
    end
  end

  test "it stores and gets job" do
    uuid = UUID.uuid1()
    {:ok, res} = LowendinsightGet.Datastore.write_job(uuid, %{:test => "test"})
    assert res == "OK"
    Getter.there_yet?(false, uuid)
    {:ok, val} = Redix.command(:redix, ["GET", uuid])
    assert val == "{\"test\":\"test\"}"
    {:ok, val} = LowendinsightGet.Datastore.get_job(uuid)
    assert val == "{\"test\":\"test\"}"
  end

  test "it handles get of invalid job" do
    {:error, reason} = LowendinsightGet.Datastore.get_job("blah")
    assert reason == "job not found"
  end

  test "it handles the overwrite of a job value" do
    uuid = UUID.uuid1()
    {:ok, _res} = LowendinsightGet.Datastore.write_job(uuid, %{:test => "will_get_overwritten"})
    Getter.there_yet?(false, uuid)
    {:ok, val} = LowendinsightGet.Datastore.get_job(uuid)
    assert val == "{\"test\":\"will_get_overwritten\"}"
    {:ok, _res} = LowendinsightGet.Datastore.write_job(uuid, %{:test => "overwritten"})
    Getter.there_yet?(false, uuid)
    {:ok, val} = LowendinsightGet.Datastore.get_job(uuid)
    assert val == "{\"test\":\"overwritten\"}"
  end

  test "it does the age math correctly", %{report: report} do
    repo = elem(elem(Poison.encode(report), 1) |> Poison.decode(), 1)
    assert false == LowendinsightGet.Datastore.too_old?(repo, 30)
    datetime_plus_30 = DateTime.utc_now() |> DateTime.add(-(86400 * 30)) |> DateTime.to_iso8601()
    repo = %{"header" => %{"end_time" => datetime_plus_30}}
    assert false == LowendinsightGet.Datastore.too_old?(repo, 30)
    datetime_plus_31 = DateTime.utc_now() |> DateTime.add(-(86400 * 31)) |> DateTime.to_iso8601()
    repo = %{"header" => %{"end_time" => datetime_plus_31}}
    assert true == LowendinsightGet.Datastore.too_old?(repo, 30)
  end

  test "it writes and reads successfully to cache", %{report: report} do
    assert {:ok, "OK"} ==
             LowendinsightGet.Datastore.write_to_cache("http://repo.com/org/repo", report)

    {:ok, report} = LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/repo", 30)
    repo = Poison.decode!(report)
    assert "https://github.com/kitplummer/xmpp4rails" == repo["data"]["repo"]
  end

  test "it returns successfully with not_found when uh" do
    assert {:error, "report not found"} ==
             LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/not_found", 30)
  end

  test "it returns correctly when cache window has expired" do
    datetime_plus_31 = DateTime.utc_now() |> DateTime.add(-(86400 * 31)) |> DateTime.to_iso8601()
    uuid = "8b08f58a-4420-11ea-8806-88e9fe666193"

    report = %{
      data: %{repo: "http://repo.com/org/expired"},
      header: %{
        end_time: datetime_plus_31,
        start_time: "2020-01-31T11:55:14.148997Z",
        uuid: uuid
      }
    }

    assert {:ok, "OK"} ==
             LowendinsightGet.Datastore.write_to_cache("http://repo.com/org/expired", report)

    Getter.there_yet?(false, uuid)

    cache_ttl = Application.get_env(:lowendinsight_get, :cache_ttl)

    assert {:error, "current report not found"} ==
             LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/expired", cache_ttl)

    {:ok, report} = LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/expired", 31)
    repo = Poison.decode!(report)
    assert "http://repo.com/org/expired" == repo["data"]["repo"]
  end
end
