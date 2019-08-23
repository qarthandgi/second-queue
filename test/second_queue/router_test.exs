defmodule SecondQueue.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias SecondQueue.Router

  @low_queue "low"
  @intermdiate_queue "intermediate"
  @emergency_queue "emergency"
  @message_1 "Get all workers back to HQ immediately"
  @message_2 "Find head of H&R for payroll information"

  @opts Router.init([])

  test "returns welcome" do
    conn = :get |> conn("/", "") |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "returns created" do
    conn =
      :get
      |> conn("/receive-message?queue=#{@low_queue}&message=#{@message_1}")
      |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 201
  end

  test "returns 404" do
    conn = :get |> conn("/non-existent", "") |> Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end
end
