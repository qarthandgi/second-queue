defmodule SecondQueue.QueueService do
  alias SecondQueue.QueueStore
  use Agent

  def handle_incoming(queue, message) do
    queue_exists = Agent.get(:qs, &Map.has_key?(&1, queue))
    unless queue_exists do
      QueueStore.add_queue(queue)
    end
    QueueStore.queue_message(queue, message)
  end
end
