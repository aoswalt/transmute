defmodule Transmute do
  @type map_key_fn :: (any -> any)

  @type transform_options :: [{:map_key, map_key_fn}]

  @spec transform(data :: map, opts :: transform_options) :: any
  def transform(data, opts) do
    map_key = Keyword.get(opts, :map_key, &identity/1)

    Transmute.map_keys(data, map_key)
  end

  @spec map_keys(data :: map, mapper :: map_key_fn) :: map
  def map_keys(data, mapper) do
    Map.new(data, fn {k, v} -> {mapper.(k), v} end)
  end

  defp identity(value), do: value
end
