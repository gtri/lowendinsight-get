defmodule LowendinsightGet.CounterAgent do
    use Agent
  
    def new_counter(number_of_processes) do
      Agent.start_link(fn -> { %{}, %{completed: 0, total: number_of_processes}} end, 
      name: :counter)
    end
  
    def get() do
      Agent.get(:counter, fn state -> state end)
    end
  
    def add(pid) do
      Agent.update(:counter, fn {proc, log} -> 
        {Map.put(proc, pid, :started), log} end)
      update()
    end
  
    def increment(pid) do
      {p, l} = get()
      cond do
        Map.fetch(p, pid) == {:ok, :started} ->
          Agent.update(:counter, fn {proc, log} -> 
            {Map.put(proc, pid, :completed), Map.put(log, :completed, log.completed + 1)} end)
          log_status() 
        true -> :ok
      end
    end
  
    def update() do
      {proc, log} = get()
      started = Enum.filter(proc, fn {_pid, status} -> status == :started end)
      cond do
        Enum.count(started) > 0 ->
          Enum.reduce(started, (log.completed), fn {pid, _status}, count ->
            if !Process.alive?(pid) do
              increment(pid)
            end
            count + 1
          end)
        true -> :ok
      end
    end
  
    def log_status() do
      {_proc, log} = get()  
      cond do
        log.total > 0 ->
          IO.puts("completed #{round(log.completed/log.total*100)}%  |  running: #{log.total - log.completed}  |  total: #{log.total}")
        true ->
          IO.puts("No processes are running..")
        end
    end

    def update_and_stop() do
      update()
      Agent.stop(:counter)
    end
  end