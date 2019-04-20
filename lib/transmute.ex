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
  def transform(data, opts) do
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

  @spec map_keys(data :: Enumerable.t(), mapper :: map_key_fn) :: map
  def map_keys(data, mapper) do
    Map.new(data, fn {k, v} -> {mapper.(k), v} end)
  end

  defp identity(value), do: value
end
