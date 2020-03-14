# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

defmodule LowendinsightGet.Endpoint do
  use Plug.Router
  # use Plug.Debugger
  use Plug.ErrorHandler

  # alias Plug.{Adapters.Cowboy}
  @template_dir "lib/lowendinsight_get/templates"

  require Logger
  alias Plug.{Adapters.Cowboy}

  plug(Plug.Logger, log: :debug)

  plug(Plug.Parsers,
    parsers: [:json, :urlencoded],
    pass: ["application/json", "text/*"],
    json_decoder: Poison
  )

  plug(:match)
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

  get "/gh_trending" do
    render(conn, "index.html",
      report: LowendinsightGet.GithubTrending.get_current_gh_trending_report()
    )
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
          case LowendinsightGet.Analysis.process_urls(urls, uuid, start_time) do
            {:ok, empty} ->
              {200, empty}

            {:error, error} ->
              {422, "LEI error - something went wrong #{error}"}
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

  # defp config, do: Application.fetch_env(:lowendinsight_get, __MODULE__)

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end

  def handle_errors(conn, _) do
    IO.puts("****HERE*****")
    send_resp(conn, conn.status, process())
  end

  defp config, do: Application.fetch_env(:lowendinsight_get, __MODULE__)
end
