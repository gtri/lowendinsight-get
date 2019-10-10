defmodule MinimalServer.Endpoint do
  use Plug.Router
  use Plug.Debugger
  use Plug.ErrorHandler

  alias MinimalServer.Router
  alias Plug.{Adapters.Cowboy, HTML}

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
    |> put_resp_content_type(@content_type)
    |> send_resp(200, message())
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
    IO.inspect rep
    cond do
      Map.has_key?(rep, "error") -> {422, message()}
      Map.has_key?(rep, "data") -> {200, Poison.encode!(rep)}
    end
  end

  defp config, do: Application.fetch_env(:minimal_server, __MODULE__)

  def handle_errors(%{status: status} = conn, %{kind: _kind, reason: _reason, stack: _stack}),
    do: send_resp(conn, status, "Something went wrong")
end
