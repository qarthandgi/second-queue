defmodule SecondQueue.QueueStore do
  # use Agent

  def start_queues_link() do
    Task.start_link(fn -> queues_loop(%{}) end)
  end

  defp queues_loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        queues_loop(map)
      {:put, key, value} ->
        IO.puts("i am here")
        queues_loop(Map.put(map, key, value))
    end
  end

  # def add_queue(queue) do
  #   Agent.update(:qs, fn list -> [queue | list] end)
  # end
end
