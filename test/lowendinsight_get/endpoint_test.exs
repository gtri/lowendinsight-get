# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts LowendinsightGet.Endpoint.init([])

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

  test "it returns 200 with a valid payload" do
    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{urls: ["https://github.com/kitplummer/xmpp4rails"]})

    # Invoke the plug
    conn = LowendinsightGet.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 200
  end

  test "it returns 422 with an invalid payload" do
    # Create a test connection
    conn = conn(:post, "/v1/analyze", %{})

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
end
