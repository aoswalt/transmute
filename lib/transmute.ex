defmodule Transmute do
  @type map_key_fn :: (any -> any)

  @spec map_keys(data :: map, mapper :: map_key_fn) :: map
  def map_keys(data, mapper) do
    Map.new(data, fn {k, v} -> {mapper.(k), v} end)
  end
end
