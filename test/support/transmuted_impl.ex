defmodule TransmutedImpl do
  defstruct [:some_key]

  defimpl Transmutable do
    def purify(_data, _opts \\ []) do
      :pure
    end

    def tarnish(_data, _opts \\ []) do
      :tarnished
    end
  end
end
