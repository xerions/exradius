defmodule Exradius.Attributes do

  def mk_dict(path, file) do
    IO.puts("compile #{file}")
    Code.eval_quoted(file, [], __ENV__)
    Path.join(path, file) |> File.stream! |> generate(file)
  end

  defp generate(stream, file) do
    name = file |> String.replace("dictionary", "attr")
                |> String.split(".")
                |> Enum.map( &String.capitalize/1 )
                |> Enum.join(".")
    modulename = "Elixir." <> name |> String.to_atom
    {vendor, macros} = Enum.reduce(stream, {nil, []}, &gen_macro/2)
    quote do
      defmodule unquote(modulename) do
        def vendor, do: unquote(vendor)
        unquote(macros)
      end
    end
  end

  defp gen_macro(<<?#, _ :: binary>>, acc), do: acc
  defp gen_macro(line, {vendor, macros}) do
    line = String.split(line, [" ", "\n", "\t"]) |> Enum.filter(&(&1 != ""))
    case line do
      ["ATTRIBUTE", name, id | _] ->
        name = vendor_strip(name, vendor) |> String.downcase |> String.replace("-", "_") |> String.to_atom
        id = build_id(vendor, id |> parse_int)
        macro = quote do
          defmacro unquote(name)(), do: unquote(id)
          defmacro unquote(name)(attr), do: {unquote(id), attr}
        end
        {vendor, [macro|macros]}
      ["VENDOR", name, id | _] ->
        {{parse_int(id), prefix(name)}, macros}
      _ ->
        {vendor, macros}
    end
  end

  def vendor_strip(name, nil), do: name
  def vendor_strip(name, {_, vendor_name}), do: strip_from(name, List.wrap(vendor_name))

  def strip_from(name, []), do: name
  def strip_from(name, [vendor_name | rest]) do
    vendor_name = vendor_name <> "-"
    vsize = byte_size(vendor_name)
    prefix = String.slice(name, 0, vsize)
    if prefix == vendor_name do
      String.slice(name, vsize, byte_size(name) - vsize)
    else
      strip_from(name, rest)
    end
  end

  def parse_int("0x" <> int), do: String.to_integer(int, 16)
  def parse_int(int), do: String.to_integer(int)

  def build_id(nil, id), do: id
  def build_id({vendor, _}, id), do: {vendor, id}

  for {vendor, prefix} <-
    [
     {"Alcatel", "ATT"},
     {"Alcatel-Lucent-Service-Router", ["Timetra", "Alc"]},
     {"Aptis", "CVX"},
     {"Bay-Networks", "Annex"},
     {"Cisco-BBSM", "CBBSM"},
     {"Cisco-VPN3000", "VPN3000"},
     {"Cisco-VPN5000", "VPN5000"},
     {"FreeRADIUS", "Freeradius"},
     {"Livingston", "LE"},
     {"Microsoft", "MS"},
     {"Netscreen", "NS"},
     {"SpringTide", "ST"},
     {"Starent", ["SN", "SNA"]},
     {"Travelping", "TP"}
    ] do
    def prefix(unquote(vendor)), do: unquote(prefix)
  end
  def prefix(vendor), do: vendor

end
