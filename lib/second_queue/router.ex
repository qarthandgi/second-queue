defmodule SecondQueue.Router do
  use Plug.Router
  use Plug.ErrorHandler

  alias SecondQueue.Plug.VerifyParams
  alias SecondQueue.QueueService


  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug VerifyParams, fields: ["queue", "message"], paths: ["/receive-message"]
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/receive-message" do
    # gather query parameters from connection
    queue = Map.get(conn.params, "queue")
    message = Map.get(conn.params, "message")

    # handle the params
    QueueService.handle_incoming(queue, message)

    send_resp(conn, 201, "Created")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    IO.inspect(kind, label: :kind)
    IO.inspect(reason, label: :reason)
    IO.inspect(stack, label: :stack)
    send_resp(conn, conn.status, "Something went wrong")
  end
end
