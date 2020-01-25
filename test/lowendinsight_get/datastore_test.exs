# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.DatastoreTest do
  use ExUnit.Case, async: true

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

end