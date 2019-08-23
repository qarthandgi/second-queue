defmodule SecondQueue.Plug.VerifyParams do
  defmodule IncompleteRequestError do
    @moduledoc """
    Raise this error when a required param isn't present
    """

    defexception message: "", plug_status: 400
  end

  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, opts) do
    if path in opts[:paths], do: verify_params!(conn.params, opts[:fields])
    conn
  end

  defp verify_params!(params, fields) do
    verified = params |> Map.keys() |> contains_fields?(fields)

    unless verified, do: raise(IncompleteRequestError)
  end

  defp contains_fields?(keys, fields), do: Enum.all?(fields, &(&1 in keys))
end
