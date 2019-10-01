defmodule MinimalServer.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @content_type "application/json"

  get "/" do
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(200, message())
  end

  post "/" do
    body = conn.body_params
    IO.inspect body
    url = body["url"]
    IO.inspect url
    conn
    |> put_resp_content_type(@content_type)
    |> send_resp(200, message(url))
  end

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  defp message do
    Poison.encode!(%{response: "this is a POSTful service, JSON body with valid git url param required and content-type set to application/json."})
  end

  defp message(url) do
    rep = AnalyzerModule.analyze url, "min"
    IO.inspect rep
    rep = Poison.decode!(rep)
    IO.inspect rep
    Poison.encode!(rep)
  end

end
