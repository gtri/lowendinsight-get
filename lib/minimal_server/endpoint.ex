defmodule MinimalServer.Endpoint do
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
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html())
  end

  post "/" do
    {status, body} =
      case conn.body_params do
        %{"url" => url} -> message(url)
        _ -> {422, message()}
      end

    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(status, body)
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  defp message do
    Poison.encode!(%{error: "this is a POSTful service, JSON body with valid git url param required and content-type set to application/json."})
  end

  defp message(url) do
    rep = AnalyzerModule.analyze url, "lei-get"
    rep = Poison.decode!(rep)
    write_event(rep)
    cond do
      Map.has_key?(rep, "error") -> {422, message()}
      Map.has_key?(rep, "data") -> {200, Poison.encode!(rep)}
    end
  end

  defp html do
    """
    <html>
      <body>
    <h1>LowEndInsight</h1>
    A simple OSS risk (bus-factor) analysis tool

    <h2>Using</h2>
    POST a JSON object with a "url" element pointing to a git repo.

    <h2>Example</h2>
          <code>
            $ curl -d '{"url":"https://bitbucket.org/kitplummer/clikan"}' -H "Content-Type: application/json" -X POST https://lowendinsight.k8s.elsys.gtri.org | jq
          </code>

    <br/><br/><b>Returns:</b>
    <br/><br/>
      <code>
      {
        "header": {
          "uuid": "c68b28dc-ec49-11e9-9470-9a8e56ec8d22",
          "start_time": "2019-10-11 17:08:41.286100Z",
          "source_client": "lei-get",
          "end_time": "2019-10-11 17:08:41.928183Z",
          "duration": 0
        },
        "data": {
          "repo": "https://bitbucket.org/kitplummer/clikan",
          "recent_commit_size_in_percent_of_codebase": 0.080078125,
          "large_recent_commit_risk": "medium",
          "functional_contributors_risk": "critical",
          "functional_contributors": 1,
          "functional_contributor_names": [
            "Kit Plummer"
          ],
          "contributor_risk": "high",
          "contributor_count": 2,
          "commit_currency_weeks": 36,
          "commit_currency_risk": "medium"
        }
      }
      </code>
      </body>
    </html>
    """
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
              Redix.command(conn, ["SET", "event-#{id}", Poison.encode!(report)])
              Redix.stop(conn)
              Logger.debug("wrote event to redis -> #{Poison.encode!(report)}")
            {:error, _reason} -> Logger.debug("no db available, processing -> #{Poison.encode!(report)}")
          end
        {:error, _reason} -> Logger.debug("no db available, processing -> #{Poison.encode!(report)}")
      end
    else
      Logger.debug("no db defined, processing -> #{Poison.encode!(report)}")
    end
  end

  defp config, do: Application.fetch_env(:minimal_server, __MODULE__)

  def handle_errors(%{status: status} = conn, %{kind: _kind, reason: _reason, stack: _stack}),
    do: send_resp(conn, status, "Something went wrong")
end
