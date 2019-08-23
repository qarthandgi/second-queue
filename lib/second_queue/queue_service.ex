defmodule SecondQueue.QueueService do
  alias SecondQueue.QueueStore
  use Agent

  {:ok, agent_pid} = QueueStore.start_queues_link()
  Process.register(agent_pid, :qs)

  def handle_incoming(queue, message) do
    queue_atom = String.to_atom(queue)
    send(:qs, {:put, queue_atom, "success"})
  end
end
