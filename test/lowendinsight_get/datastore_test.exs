# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.DatastoreTest do
  use ExUnit.Case, async: true

  setup_all do
    report = %{ report: %{
      repos: [
        %{
          data: %{
            config: [
              high_contributor_level: 3,
              high_currency_level: 52,
              critical_functional_contributors_level: 2,
              medium_contributor_level: 5,
              high_large_commit_level: 0.15,
              medium_currency_level: 26,
              critical_large_commit_level: 0.3,
              critical_currency_level: 104,
              medium_large_commit_level: 0.05,
              medium_functional_contributors_level: 5,
              critical_contributor_level: 2,
              high_functional_contributors_level: 3
            ],
            repo: "https://github.com/kitplummer/ovmtb2",
            results: %{
              commit_currency_risk: "critical",
              commit_currency_weeks: 111,
              contributor_count: 2,
              contributor_risk: "high",
              functional_contributor_names: ["Kit Plummer"],
              functional_contributors: 1,
              functional_contributors_risk: "critical",
              large_recent_commit_risk: "low",
              recent_commit_size_in_percent_of_codebase: 8.213552361396304e-4,
              top10_contributors: [%{"Kit Plummer" => 10}, %{"Cody Martin" => 1}]
            },
            risk: "critical"
          },
          header: %{
            duration: 1,
            end_time: "2020-01-31T11:55:15.047211Z",
            library_version: "",
            source_client: "here",
            start_time: "2020-01-31T11:55:14.148997Z",
            uuid: "8b08f58a-4420-11ea-8806-88e9fe666193"
          }
        }
      ],
      uuid: "8b090700-4420-11ea-bb6d-88e9fe666193"
    }}
    [report: report]
  end

  test "it stores and gets job" do
    uuid = UUID.uuid1

    {:ok, res} = LowendinsightGet.Datastore.write_job(uuid, %{:test => "test"})
    assert res == "OK"
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
    uuid = UUID.uuid1
    {:ok, _res} = LowendinsightGet.Datastore.write_job(uuid, %{:test => "will_get_overwritten"})
    {:ok, val} = LowendinsightGet.Datastore.get_job(uuid)
    assert val == "{\"test\":\"will_get_overwritten\"}"
    {:ok, _res} = LowendinsightGet.Datastore.write_job(uuid, %{:test => "overwritten"})
    {:ok, val} = LowendinsightGet.Datastore.get_job(uuid)
    assert val == "{\"test\":\"overwritten\"}"
  end

  test "it does the age math correctly", %{report: report} do
    report = elem(elem(JSON.encode(report),1) |> JSON.decode(),1)
    repo = List.first(report["report"]["repos"])
    assert false == LowendinsightGet.Datastore.too_old?(repo, 30)
    datetime_plus_30 = DateTime.utc_now |> DateTime.add(-(86400 * 30)) |> DateTime.to_iso8601
    repo = %{"header" => %{"end_time" => datetime_plus_30}}
    assert false == LowendinsightGet.Datastore.too_old?(repo, 30)
    datetime_plus_31 = DateTime.utc_now |> DateTime.add(-(86400 * 31)) |> DateTime.to_iso8601
    repo = %{"header" => %{"end_time" => datetime_plus_31}}
    assert true == LowendinsightGet.Datastore.too_old?(repo, 30)
  end
  
  test "it writes and reads successfully to cache", %{report: report} do
    assert {:ok, "OK"} == LowendinsightGet.Datastore.write_to_cache("http://repo.com/org/repo", report)
    {:ok, report} = LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/repo", 30)
    report = JSON.decode!(report)
    repo = List.first(report["report"]["repos"])
    assert "https://github.com/kitplummer/ovmtb2" == repo["data"]["repo"]
  end

  test "it returns successfully with not_found when uh" do
    assert {:error, "report not found"} == LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/not_found", 30)
  end

  test "it returns correctly when cache window has expired" do
    datetime_plus_31 = DateTime.utc_now |> DateTime.add(-(86400 * 31)) |> DateTime.to_iso8601
    report = %{ report: %{
      repos: [
        %{
          data: %{repo: "http://repo.com/org/expired"},
          header: %{
            end_time: datetime_plus_31,
            start_time: "2020-01-31T11:55:14.148997Z",
            uuid: "8b08f58a-4420-11ea-8806-88e9fe666193"
          }
        }
      ],
      uuid: "8b090700-4420-11ea-bb6d-88e9fe666193"
    }}
    assert {:ok, "OK"} == LowendinsightGet.Datastore.write_to_cache("http://repo.com/org/expired", report)
    assert {:error, "current report not found"} == LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/expired", 30)
    {:ok, report} = LowendinsightGet.Datastore.get_from_cache("http://repo.com/org/expired", 31)
    report = JSON.decode!(report)
    repo = List.first(report["report"]["repos"])
    assert "http://repo.com/org/expired" == repo["data"]["repo"]
  end

end