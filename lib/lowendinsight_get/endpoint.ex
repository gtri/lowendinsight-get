# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Endpoint do
  use Plug.Router
  # use Plug.Debugger
  use Plug.ErrorHandler

  alias Plug.{Adapters.Cowboy}

  require Logger

  plug(Plug.Logger, log: :debug)
  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json", "text/plain"],
    json_decoder: Poison
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

  get "/v1/analyze/:uuid" do
    {status, body} =
      case LowendinsightGet.Datastore.get_job(uuid) do
        {:ok, job} ->
          {200, job}

        {:error, _job} ->
          {404, Poison.encode!(%{:error => "no job found."})}
      end

    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(status, body)
  end

  post "/v1/analyze" do
    start_time = DateTime.utc_now()
    uuid = UUID.uuid1()

    {status, body} =
      case conn.body_params do
        %{"urls" => urls} ->
          if :ok == Helpers.validate_urls(urls) do
            Logger.debug("started #{uuid} at #{start_time}")

            ## Get empty report for new job to respond the request with
            empty = AnalyzerModule.create_empty_report(uuid, urls, start_time)
            LowendinsightGet.Datastore.write_job(uuid, empty)

            case LowendinsightGet.AnalysisSupervisor.perform_analysis(uuid, urls, start_time) do
              {:ok, task} ->
                Logger.info(task)
                {200, Poison.encode!(empty)}

              {:error, error} ->
                {422, "LEI error - something went wrong #{error}"}
            end
          else
            {422, process()}
          end

        _ ->
          {422, process()}
      end

    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(status, body)
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  defp process do
    Poison.encode!(%{
      error:
        "this is a POSTful service, JSON body with valid git url param required and content-type set to application/json.  e.g. {\"urls\": [\"https://gitrepo/org/repo\", \"https://gitrepo/org/repo1\"]"
    })
  end

  defp config, do: Application.fetch_env(:lowendinsight_get, __MODULE__)

  def handle_errors(conn, _) do
    send_resp(conn, conn.status, process())
  end
end
