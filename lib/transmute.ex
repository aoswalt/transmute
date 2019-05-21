defmodule Transmute do
  @type map_key_fn :: (any -> any)
  @type map_shape_fn :: (map -> any)

  @type transform_options :: [
          {:map_key, map_key_fn}
          | {:map_shape, map_shape_fn}
          | {:key_map, map}
          | {:only, list}
          | {:except, list}
        ]

  @spec transform(data :: map, opts :: transform_options) :: any
  def transform(data, call_opts \\ []) when is_map(data) do
    defaults = Application.get_env(:transmute, :defaults, [])

    opts = Enum.concat(call_opts, defaults)

    if Keyword.has_key?(opts, :only) and Keyword.has_key?(opts, :except) do
      raise RuntimeError, message: ":only and :except should not be used together"
    end

    map_key = Keyword.get(opts, :map_key, &identity/1)
    map_shape = Keyword.get(opts, :map_shape, &identity/1)
    key_map = Keyword.get(opts, :key_map, %{})
    only = Keyword.get(opts, :only, Map.keys(data))
    except = Keyword.get(opts, :except, [])

    {overrides, non_overrides} =
      data
      |> Map.take(only)
      |> Map.drop(except)
      |> Enum.split_with(fn {k, _v} -> Map.has_key?(key_map, k) end)

    override_map = map_keys(overrides, &Map.get(key_map, &1))

    non_overrides
    |> Transmute.map_keys(map_key)
    |> Map.merge(override_map)
    |> map_shape.()
  end

  @spec purify(Transmutable.t(), options :: Keyword.t()) :: any
  def purify(data, opts \\ []) do
    with_struct = Keyword.get(opts, :with, Map)
    protocol_module = Module.concat(Transmutable, with_struct)

    new_opts = Keyword.delete(opts, :with)

    protocol_module.purify(data, new_opts)
  end

  @spec tarnish(Transmutable.t(), options :: Keyword.t()) :: any
  defdelegate tarnish(data, opts \\ []), to: Transmutable

  @spec map_keys(data :: Enumerable.t(), mapper :: map_key_fn) :: map
  def map_keys(data, mapper) do
    Map.new(data, fn {k, v} -> {mapper.(k), v} end)
  end

  defp identity(value), do: value

  @spec camelize(atom | String.t()) :: String.t()
  def camelize(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> camelize()
  end

  def camelize(string) when is_binary(string) do
    string
    |> Macro.camelize()
    |> (fn word -> Regex.replace(~r/^./, word, &String.downcase/1) end).()
  end

  @spec invert_map(map) :: map
  def invert_map(map) do
    Map.new(map, fn {k, v} -> {v, k} end)
  end
end
