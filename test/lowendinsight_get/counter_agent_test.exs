defmodule LowendinsightGet.CounterAgentTest do
    use ExUnit.Case, async: true

    test "counter agent adds pid and url, increments, and stops" do        
        number_of_urls = 1
        {:ok, _counter} = LowendinsightGet.CounterAgent.new_counter(number_of_urls)

        assert Process.whereis(:counter) != nil

        {proc, _log} = LowendinsightGet.CounterAgent.get()
        assert map_size(proc) == 0

        LowendinsightGet.CounterAgent.add(self(), "url")
        {proc, log} = LowendinsightGet.CounterAgent.get()

        assert Map.fetch(proc, self()) == {:ok, :running}
        assert map_size(proc) == 1
        assert log.completed == 0
        assert log.total == number_of_urls
        assert LowendinsightGet.CounterAgent.log_status({proc, log}) == :logged

        LowendinsightGet.CounterAgent.increment(self())
        {proc, log} = LowendinsightGet.CounterAgent.get()
        assert log.completed == 1
        assert LowendinsightGet.CounterAgent.log_status({proc, log}) == :no_log

        LowendinsightGet.CounterAgent.update_and_stop()
        assert Process.whereis(:counter) == nil
    end
end