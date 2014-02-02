defmodule Exradius.Attributes do

  def mk_dict(path, file) do
    IO.puts("compile #{file}")
    Code.eval_quoted(file, [], __ENV__)
    Path.join(path, file) |> File.stream! |> generate(file)
  end

  defp generate(stream, file) do
    name = String.split(file, ".") |> Enum.map( &String.capitalize/1 ) |> Enum.join(".")
    modulename = "Elixir.Exradius." <> name |> binary_to_atom
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
        name = vendor_strip(name, vendor) |> String.downcase |> String.replace("-", "_") |> binary_to_atom
        id = build_id(vendor, id |> parse_int)
        macro = quote do
          defmacro unquote({name, [context: __ENV__.context], Elixir}), do: unquote(id)
        end
        {vendor, [macro|macros]}
      ["VENDOR", name, id | _] ->
        {{parse_int(id), name}, macros}
      _ ->
        {vendor, macros}
    end
  end

  def vendor_strip(name, nil), do: name
  def vendor_strip(name, {_, vendor_name}) do
    vendor_name = vendor_name <> "-"
    vsize = size(vendor_name)
    prefix = String.slice(name, 0, vsize)
    if prefix == vendor_name do
      String.slice(name, vsize, size(name) - vsize)
    else
      name
    end
  end

  def parse_int("0x" <> int), do: binary_to_integer(int, 16)
  def parse_int(int), do: binary_to_integer(int)

  def build_id(nil, id), do: id
  def build_id({vendor, _}, id), do: {vendor, id}

end
