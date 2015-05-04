if Code.ensure_loaded?(:meck) do
  defmodule Exradius.Dev.Client do
    alias Exradius.Dev.Server
    import Exradius.Data
    @moduledoc """
    Module implements a mocked eradius client. Use `init/0` before to mock the needed function calls.
    """

    @doc """
    Mocks :gen_udp.send/4 and :eradius_inet.setopts/2, that all requests, which will be sent with this
    modules, are answers per message parsing, instead.
    """
    def init do
      :meck.new(:gen_udp, [:unstick, :passthrough])
      :meck.expect(:gen_udp, :send, fn(socket, _ip, _port, req) -> send(socket, {:udp, req}) end)
      :meck.new(:eradius_inet, [:passthrough])
      :meck.expect(:eradius_inet, :setopts, fn(_a, _b) -> :ok end)
    end

    @doc """
    Start named client for ip (ip are mocked, that means you can use every ip for your client),
    which are doesn't sent on wire, but directly as erlang message representing
    incomming upd packet. It allows to simulate different ongoing ips for your radius configuration.
    """
    def start_link(name, ip) do
      Server.start_link(name, ip)
    end

    @doc """
    Sent to from client to server, which should be represented as a normal server for `eradius_client`
    """
    def request(client, {{a, b, c, d}, server_port, secret}, request) do
      to = :"eradius_server_#{a}.#{b}.#{c}.#{d}:#{server_port}"
      {from, port, reqid} = Server.reqid(client)
      req = radius_request(request, reqid: reqid, secret: secret)
        |> authenticator()
        |> :eradius_lib.encode_request()
      request_send(to, from, secret, port, req, 3)
    end

    defp request_send(_to, _from, _secret, _port, _req, 0) do
      {:error, :timeout}
    end
    defp request_send(to, from, secret, port, req, n) do
      send to, {:udp, self, from, port, req}
      receive do
        {:udp, req} -> :eradius_lib.decode_request(req, secret)
      after
        5000 -> request_send(to, from, secret, port, req, n - 1)
      end
    end

    defp authenticator(radius_request(cmd: cmd) = req) when cmd in [:request, :coareq, :discreq] do
      radius_request(req, authenticator: :eradius_lib.random_authenticator)
    end
    defp authenticator(radius_request(cmd: :accreq) = req) do
      radius_request(req, authenticator: :eradius_lib.zero_authenticator)
    end
  end
end
