defmodule SecondQueue.QueueStore do
  use Agent

  def start_queues_link() do
    Agent.start_link(fn -> %{} end)
  end

  def get_queue_info(key) do
    Agent.get(:qs, &Map.get(&1, key))
  end

  def loop_queue(queue) do
    receive do
      after
        1_000 ->
          messages = Agent.get(:qs, &Map.get(&1, queue))
          if length(messages) > 0 do
            {last_element, updated_messages} = List.pop_at(messages, -1)
            Agent.update(:qs, &Map.put(&1, queue, updated_messages))
            IO.puts "Queue: #{queue}"
            IO.puts "Message: #{last_element}"
            IO.puts "\n"
            loop_queue(queue)
          else
            pid = Process.whereis(String.to_atom(queue <> "-interval-check"))
            Agent.update(:qs, &Map.delete(&1, queue))
            Process.exit(pid, :normal)
          end
    end
  end

  def add_queue(queue) do
    Agent.update(:qs, fn agent ->
      interval_process_pid = spawn(fn -> loop_queue(queue) end)
      Process.register(interval_process_pid, String.to_atom(queue <> "-interval-check"))
      Map.put(agent, queue, [])
    end)
  end

  def queue_message(queue, msg) do
    queue_messages = Agent.get(:qs, &Map.get(&1, queue))
    updated_messages = [msg | queue_messages]
    Agent.update(:qs, &Map.put(&1, queue, updated_messages))

  end
end
