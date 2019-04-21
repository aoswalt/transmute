defprotocol Transmutable do
  @type t :: any

  @spec purify(t, options :: Keyword.t()) :: any
  def purify(data, opts \\ [])

  @spec tarnish(t, options :: Keyword.t()) :: any
  def tarnish(data, opts \\ [])
end

defimpl Transmutable, for: Map do
  defdelegate purify(map, opts \\ []), to: Transmute, as: :transform
  defdelegate tarnish(map, opts \\ []), to: Transmute, as: :transform
end
