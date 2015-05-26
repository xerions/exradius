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
  # if you are using a dictionary other than the default, you *must* uncomment
  # the following line and add the missing dictionary. The following example is also
  # using the cisco dictionary.
  #tables: [:dictionary, :dictionary_cisco],
  # defines node, where in cluster should be radius callback applied
  session_nodes: [node()],
  # Clients that are able to connect shold be configured here.
  # Every simbolic name server should be configured to accept requests from eradius clients
  root: [
    # every configuration is {name, arguments for a callback} and list of accepted clients with ip and secret
    { {'root', []}, [{'192.168.17.1', "secret"}] }
  ]

