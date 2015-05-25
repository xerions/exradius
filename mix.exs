defmodule Exradius.Mixfile do
  use Mix.Project

  def project do
    [ app: :exradius,
      version: "0.0.1",
      deps: deps(Mix.env) ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }

  defp deps(:mock) do
    [{ :meck,    github: "eproxus/meck", optional: true }]
  end
  defp deps(_) do
    [{ :eradius, github: "travelping/eradius" }]
  end
end
