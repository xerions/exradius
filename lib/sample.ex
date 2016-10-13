if Mix.env == :dev do
  defmodule Sample do
    @moduledoc """
    Example of using eradius, will be updated, as it will be have better elixir interface.
    """
    import Exradius.Data

    # Require dictionary macros
    require Attr

    @doc """
    Handmade start of server.

    Instead of :application.ensure_all_started(:eradius)
    add :eradius to :applications

    Instead of spawn, simply add :eradius.modules_ready([__MODULE__]) to your Application
    start/2 callback.
    """
    def server() do
      :application.ensure_all_started(:eradius)
      # See config/config.exs for example fonfiguration
      spawn(fn ->
              # this should be called in application starts, that eradius linked to application and
              # stops distributing requests to a module, if application is not running
              :eradius.modules_ready([__MODULE__])
              :timer.sleep(:infinity)
            end)
    end

    @allowed_users ["foo", "bar"]
    @doc """
    Implementation of a callback.
    """
    def radius_request(radius_request(cmd: :request) = request, _nas_prop, _handler_args) do
      case :eradius_lib.get_attr(request, Attr.user_name) in @allowed_users do
        true  -> {:reply, radius_request(cmd: :accept)}
        false -> {:reply, radius_request(cmd: :reject)}
      end
    end

    @doc """
    Simple client code for testing it
    """
    @secret "secret"
    @server {{127, 0, 0, 1}, 1812, @secret}
    def client() do
      request = radius_request(cmd: :request) |> :eradius_lib.set_attributes([{Attr.user_name, "foo"}])
      case :eradius_client.send_request(@server, request) do
        {:ok, result, auth} ->
          :eradius_lib.decode_request(result, @secret, auth)
        error ->
          error
      end
    end
  end
end
