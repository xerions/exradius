if Code.ensure_loaded?(:meck) do
  defmodule Exradius.Dev.Server do
    @moduledoc """
    This modules uses for Exradius.Dev.Client as state holder for ongoing request id
    and port, as the server checks it.
    For request id it goes from 0 to 255, and after it get to next ports. Port range is from
    20000 till 30000.
    """
    defstruct ip: nil, port: 20000, reqid: 0, clients: %{}

    def start_link(name, ip) do
      {:ok, pid} = Agent.start_link(fn -> %__MODULE__{ip: ip} end)
      Process.register(pid, name)
    end

    @doc """
    Get next request id and other client information, like ip, port, from which the requests
    are sent. This requests update request id.
    """
    def reqid(name) do
      Agent.get_and_update(name,
        fn(state = %{reqid: reqid, port: port, ip: ip}) ->
          {reqid, port} = if reqid >= 255, do: {0, port + 1},
                                           else: {reqid, port}
          port = if port > 30000, do: 20000, else: port
          {{ip, port, reqid + 1}, %{state | reqid: reqid + 1, port: port}}
        end)
    end

    def save(name, key, pid) do
      Agent.update(name, fn(state = %{clients: clients}) ->
        %{state | clients: Map.put(clients, key, pid)}
      end)
    end

    def get(name, key) do
      Agent.get(name, fn(_state = %{clients: clients}) -> Map.get(clients, key) end)
    end
  end
end
