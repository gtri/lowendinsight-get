defmodule LowendinsightGet.Application do
  use Application

  alias LowendinsightGet.Endpoint

  def start(_type, _args),
    do: Supervisor.start_link(children(), opts())

  defp children do
    [
      Endpoint
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: LowendinsightGet.Supervisor
    ]
  end
end
