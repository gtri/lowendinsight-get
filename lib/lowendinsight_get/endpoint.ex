# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Endpoint do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler

  alias Plug.{Adapters.Cowboy}

  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json", "text/plain"],
    json_decoder: JSON
  )

  plug(:dispatch)

  @content_type "application/json"

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    with {:ok, [port: port] = config} <- config() do
      Logger.info("Starting server at http://localhost:#{port}/")
      Cowboy.http(__MODULE__, [], config)
    end
  end

  get "/" do
    {:ok, html} = File.read("#{:code.priv_dir(:lowendinsight_get)}/static/index.html")
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  post "/v1/analyze" do
    {status, body} =
      case conn.body_params do
        %{"urls" => urls} -> 
          rep = multi_process(urls)
          cond do
            Map.has_key?(rep, :report) -> {200, JSON.encode!(rep)}
            Map.has_key?(rep, :error) -> {422, JSON.encode!(rep)}
          end
        _ -> {422, process()}
      end

    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(status, body)
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  defp process do
    JSON.encode!(%{error: "this is a POSTful service, JSON body with valid git url param required and content-type set to application/json."})
  end

  defp process(url) do
    response = AnalyzerModule.analyze url, "lei-get"
    case response do
      {:ok, rep} ->
        rep |> write_event
        rep
      {:error, rep} ->
        %{error: rep} |> write_event
        %{error: rep}
    end
  end

  # This currently has a timeout of infinity, because if any of the spun out tasks times out
  # the function will error in whole
  # Max concurrency is hard code, but might should be a config value
  defp multi_process(urls) do
    response = AnalyzerModule.analyze urls, "lei-get"
    case response do
      {:ok, rep} ->
        rep |> write_event
        rep
      {:error, rep} ->
        %{error: rep} |> write_event
        %{error: rep}
    end
  end

  defp write_event(report) do
    if Application.get_all_env(:redix) != [] do
      case Redix.start_link(
        host: Application.fetch_env!(:redix, :server),
        port: Application.fetch_env!(:redix, :port),
        database: Application.fetch_env!(:redix, :db)
      ) do
        {:ok, conn} ->
          case Redix.command(conn, ["INCR", "event:id"]) do
            {:ok, id} ->
              Redix.command(conn, ["SET", "event-#{id}", JSON.encode!(report)])
              Redix.stop(conn)
              Logger.debug("wrote event to redis -> #{JSON.encode!(report)}")
            {:error, _reason} -> Logger.debug("no db available, processing -> #{JSON.encode!(report)}")
          end
        {:error, _reason} -> Logger.debug("no db available, processing -> #{JSON.encode!(report)}")
      end
    else
      Logger.debug("no db defined, processing -> #{JSON.encode!(report)}")
    end
  end

  defp config, do: Application.fetch_env(:lowendinsight_get, __MODULE__)

  def handle_errors(%{status: status} = conn, %{kind: _kind, reason: _reason, stack: _stack}),
    do: send_resp(conn, status, "Something went wrong")
end
