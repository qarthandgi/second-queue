defmodule SecondQueue.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias SecondQueue.Router

  @low_queue "low"
  @intermediate_queue "intermediate"
  # @emergency_queue "emergency"
  @message_1 "Get all workers back to HQ immediately"
  @message_2 "We need to talk yesterday, at the latest."

  @opts Router.init([])

  test "returns welcome" do
    conn = :get |> conn("/", "") |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "ensures messages are placed in the queue and are ready to be outputted" do
    # create two connections, one right after another, which will cause the `low` queue to fill with 2 entries
    conn_1 =
      :get
      |> conn("/receive-message?queue=#{@low_queue}&message=#{@message_1}")
      |> Router.call(@opts)
    assert conn_1.state == :sent
    assert conn_1.status == 200

    conn_2 =
      :get
      |> conn("/receive-message?queue=#{@low_queue}&message=#{@message_2}")
      |> Router.call(@opts)
    assert conn_2.state == :sent
    assert conn_2.status == 200

    # now the `:qs` (queue store) process should have two messages in the `low` queue, let's confirm that
    queue_messages = Agent.get(:qs, &Map.get(&1, @low_queue))
    expected_messages = [@message_1, @message_2] # this is the order that we sent the messages in
    assert queue_messages == Enum.reverse(expected_messages) # but we append items so we need to compare a reversed list

  end

  test "doesn't print messages from each queue more than once every second" do
    conn_1 =
      :get
      |> conn("/receive-message?queue=#{@intermediate_queue}&message=#{@message_1}")
      |> Router.call(@opts)
    assert conn_1.state == :sent
    assert conn_1.status == 200

    conn_2 =
      :get
      |> conn("/receive-message?queue=#{@intermediate_queue}&message=#{@message_2}")
      |> Router.call(@opts)
    assert conn_2.state == :sent
    assert conn_2.status == 200

    # Messages should immediately be availabe ont eh `intermediate` queue
    current_queue_messages = Agent.get(:qs, &Map.get(&1, @intermediate_queue))
    # reverseing b/c of how we process incoming messages: placing new item at head is faster than traversing to end of list
    expected_current_queue_messages = Enum.reverse([@message_1, @message_2])
    assert current_queue_messages == expected_current_queue_messages

    # Now let's sleep for a little over HALF a second, therefore both items should STILL be in the `intermediate` queue
    # (They should still be in there because a queue checks every second for items, even when created, it waits a
    # second before checking the queue)
    Process.sleep(600)
    current_queue_messages = Agent.get(:qs, &Map.get(&1, @intermediate_queue))
    expected_current_queue_messages = Enum.reverse([@message_1, @message_2])
    assert current_queue_messages == expected_current_queue_messages

    # Now we're going to wait another 600 milliseconds. At this point, one item should have been printed, and there
    # should be one item left in the queue
    Process.sleep(600)
    current_queue_messages = Agent.get(:qs, &Map.get(&1, @intermediate_queue))
    expected_current_queue_messages = [@message_2]
    assert current_queue_messages == expected_current_queue_messages

    # Now we're going to wait a FULL second (total is ~2.2 seconds). At this point, both items in the `intermediate`
    # should have been printed to the output, and there should be nothing left in the `intermediate` queue
    Process.sleep(1000)
    current_queue_messages = Agent.get(:qs, &Map.get(&1, @intermediate_queue))
    expected_current_queue_messages = []
    assert current_queue_messages == expected_current_queue_messages
  end

  test "returns 404 on unrecognized endpoint or verb" do
    conn = :get |> conn("/non-existent", "") |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
