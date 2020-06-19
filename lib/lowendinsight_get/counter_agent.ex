defmodule LowendinsightGet.CounterAgent do
    use Agent
    require Logger
  
    def new_counter(number_of_processes) do
      Agent.start_link(fn -> { %{}, %{completed: 0, total: number_of_processes}} end, 
      name: :counter)
    end
  
    def get() do
      Agent.get(:counter, fn state -> state end)
    end
  
    def add(pid, url) do
      Agent.update(:counter, fn {proc, log} -> 
        if map_size(proc) == 0, do: IO.puts "\n"
        IO.puts "running process ##{map_size(proc) + 1} -> #{url}"
        {Map.put(proc, pid, :running), log} 
      end)
      update()
    end
  
    def increment(pid) do
      Agent.update(:counter, fn {proc, log} -> 
        if Map.fetch(proc, pid) == {:ok, :running} do
          log_status({proc, log})
          {Map.put(proc, pid, :completed), Map.put(log, :completed, log.completed + 1)} 
          else {proc, log} 
        end 
      end)
    end
  
    def update() do
      {proc, _log} = get()
      Enum.filter(proc, fn {_pid, status} -> status == :running end)
      |> Enum.each(fn {pid, _status} -> if !Process.alive?(pid), do: increment(pid) end)
    end
  
    def log_status({proc, log}) do
      completed = log.completed + 1
      cond do
        log.total > log.completed && log.total > 0 ->
          IO.puts "completed #{round(completed/log.total * 100)}% " <> 
          (if (completed < log.total), do: " ", else: "") <> "|  running: #{map_size(proc) - completed}  |  total urls: #{log.total}"
        true -> :ok
        end
    end

    def update_and_stop() do
      update()
      Agent.stop(:counter)
    end
  end