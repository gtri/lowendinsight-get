# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts LowendinsightGet.Endpoint.init([])

  setup_all do
    Redix.command(:redix, ["FLUSHDB"])

    on_exit(fn ->
      Task.Supervisor.children(LowendinsightGet.AnalysisSupervisor)
      |> Enum.map(fn child ->
        Task.Supervisor.terminate_child(LowendinsightGet.AnalysisSupervisor, child)
      end)
    end)
  end

  test "it returns HTML" do
    # Create a test connection
    conn = conn(:get, "/")

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "<html>")
  end

  test "it returns error when error" do
    conn = conn(:get, "/blah")
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "it returns 200 with a valid payload" do
    Redix.command(:redix, ["DELETE", "https://github.com/gbtestee/gbtestee"])
    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{urls: ["https://github.com/gbtestee/gbtestee"]})

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
    :timer.sleep(5000)
    json = Poison.decode!(conn.resp_body)
    conn = conn(:get, "/v1/analyze/#{json["uuid"]}")
    conn = LowendinsightGet.Endpoint.call(conn, @opts)
    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert "complete" == json["state"]
  end

  test "it returns 200 with a valid payload when cached" do
    Redix.command(:redix, ["DELETE", "https://github.com/kitplummer/git-author"])
    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{urls: ["https://github.com/kitplummer/git-author"]})

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
    :timer.sleep(2000)
    json = Poison.decode!(conn.resp_body)
    conn = conn(:get, "/v1/analyze/#{json["uuid"]}")
    conn = LowendinsightGet.Endpoint.call(conn, @opts)
    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert "complete" == json["state"]

    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{urls: ["https://github.com/kitplummer/git-author"]})

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
    :timer.sleep(1000)
    json = Poison.decode!(conn.resp_body)
    conn = conn(:get, "/v1/analyze/#{json["uuid"]}")
    conn = LowendinsightGet.Endpoint.call(conn, @opts)
    assert conn.status == 200
    json = Poison.decode!(conn.resp_body)
    assert "complete" == json["state"]
  end

  test "it returns 422 with an empty payload" do
    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{})

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 422
  end

  test "it returns 422 with an invalid json payload" do
    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{urls: ["htps://github.com/kitplummer/xmpp4rails"]})

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 422
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end

  test "it returns 200 for the /gh_trending endpoint" do
    # Create a test connection
    conn = conn(:get, "/gh_trending")
    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "<html>")
  end

  test "it returns 200 for the /gh_trending/language endpoint" do
    # Create a test connection
    conn = conn(:get, "/gh_trending/elixir")
    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "<html>")
  end

  test "it returns 200 for the /doc endpoint" do
    # Create a test connection
    conn = conn(:get, "/doc")

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert String.contains?(conn.resp_body, "<html>")
  end

  test "it returns 200 when report is valid for the /url= endpoint" do
     # Create a test connection
     conn = conn(:get, "/url=https%3A%2F%2Fgithub.com%2Felixir-lang%2Fex_doc?")

     # Invoke the plug
     conn = LowendinsightGet.Endpoint.call(conn, @opts)
 
     # Assert the response and status
     assert conn.state == :sent
     assert conn.status == 200
     assert String.contains?(conn.resp_body, "<html>")
  end

  test "it returns 401 when report is invalid for the /url= endpoint" do
      # Create a test connection
      conn = conn(:get, "/url=https%3A%2F%2Fwww.youtube.com")

      # Invoke the plug
      conn = LowendinsightGet.Endpoint.call(conn, @opts)
  
      # Assert the response and status
      assert conn.state == :sent
      assert conn.status == 401
  end

  test "it returns 200 when url is valid for /validate-url endpoint" do
    # Create a test connection
    conn = conn(:get, "/validate-url/url=https%3A%2F%2Fgithub.com%2Felixir-lang%2Fex_doc?")

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "it returns 200 for the /v1/gh_trending/process endpoint" do
    # Create a test connection
    conn = conn(:post, "/v1/gh_trending/process")

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "it returns 201 when url is invalid for /validate-url endpoint" do
    # Create a test connection
    conn = conn(:get, "/validate-url/url=www.url.com")

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 201
  end
end
