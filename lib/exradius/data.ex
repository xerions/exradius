defmodule Exradius.Data do
  @moduledoc """
  Extract records `nas_prop`, `radius_request`, `attribute` from eradius/include for using it from
  elixir code.
  """
  require Record

  Record.defrecord :nas_prop, Record.extract(:nas_prop, from_lib: "eradius/include/eradius_lib.hrl")
  Record.defrecord :radius_request, Record.extract(:radius_request, from_lib: "eradius/include/eradius_lib.hrl")
  Record.defrecord :attribute, Record.extract(:attribute, from_lib: "eradius/include/eradius_dict.hrl")
end
