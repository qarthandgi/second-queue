defmodule SecondQueue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: SecondQueue.Worker.start_link(arg)
      # {SecondQueue.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: SecondQueue.Router, options: [port: 8080]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SecondQueue.Supervisor]
    Logger.info("Starting SecondQueue....")
    Supervisor.start_link(children, opts)
  end
end
