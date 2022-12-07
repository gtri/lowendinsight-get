defmodule LowendinsightGet.Auth do
  import Plug.Conn
  require Logger
  @secret "my super secret"
  @alg "HS256"
  @signer Joken.Signer.create(@alg, @secret)

  def init(opts) do
    opts
  end

  defp authenticate({conn, "Bearer " <> jwt}) do
    case Joken.verify(jwt, @signer) do
      {:ok, _} ->
        Logger.debug("Valid Token, proceed")
        conn
      {:error, err} -> send_401(conn, %{error: err})
    end
  end

  defp authenticate({conn}) do
    send_401(conn)
  end

  defp send_401(
         conn,
         data \\ %{message: "Please make sure you have authentication header"}
       ) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Poison.encode!(data))
    |> halt
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [token] -> {conn, token}
      _ -> {conn}
    end
  end

  def call(%Plug.Conn{request_path: path} = conn, _opts) do
    ## Only do auth on API bits
    case String.contains?(path, "/v1") do
      true ->
        conn
        |> get_auth_header
        |> authenticate
      _ -> conn
    end
  end
end

defmodule LowendinsightGet.Auth.Token do
  use Joken.Config
end
