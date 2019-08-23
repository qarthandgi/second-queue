defmodule SecondQueueTest do
  use ExUnit.Case
  doctest SecondQueue

  test "greets the world" do
    assert SecondQueue.hello() == :world
  end
end
