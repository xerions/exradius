use Mix.Config

# simple trick to avoid overwriting defaults of eradius on loading
:application.load(:eradius)

  # defines servers and ports, from which should radius server accept requests
  # each server should have simpolic name
config :eradius, :servers,
  root: {'127.0.0.1', [1812, 1813]}

config :eradius,
  # defines radius callback, which should be called
  radius_callback: Sample,
  # defines node, where in cluster should be radius callback applied
  session_nodes: [node()],
  # every simbolic name server should be configured to accept requests from eradius clients
  root: [
    # every configuration is {name, arguments for a callback} and list of accepted clients with ip and secret
    { {'root', []}, [{'127.0.0.1', "secret"}] }
  ]

