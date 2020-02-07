# Copyright (C) 2020 by the Georgia Tech Research Institute (GTRI)
# This software may be modified and distributed under the terms of
# the BSD 3-Clause license. See the LICENSE file for details.

ExUnit.start()

defmodule Getter do
  def there_yet?(test, key) do
    case test do
      true ->
        :ok

      false ->
        :timer.sleep(100)
        case Redix.command(:redix, ["GET", key]) do
          {:ok, _} -> there_yet?(true, key)
          {:error, _} -> there_yet?(false, key)
        end
    end
  end
end
