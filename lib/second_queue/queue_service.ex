defmodule SecondQueue.QueueService do
  alias SecondQueue.QueueStore
  use Agent

  {:ok, agent_pid} = QueueStore.start_queues_link()
  IO.puts(inspect {:ok, agent_pid})
  IO.puts(Process.register(agent_pid, :qs))
  IO.puts(inspect Process.whereis(:qs))

  def handle_incoming(queue, message) do
    # QueueStore.add_queue(queue)
    # content = Agent.get(:qs, fn content -> content end)
    IO.puts("looking...")
    IO.puts(Process.whereis(:qs))

    queue_atom = String.to_atom(queue)
    send(:qs, {:put, queue_atom, "success"})
  end
end
