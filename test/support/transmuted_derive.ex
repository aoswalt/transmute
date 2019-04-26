defmodule TestFns do
  def underscore(camel) do
    camel |> Macro.underscore() |> String.to_existing_atom()
  end
end

defmodule TransmutedDerive do
  @derive {Transmutable, tarnish_key: &Transmute.camelize/1, purify_key: &TestFns.underscore/1}
  defstruct [:some_key]
end

defmodule TransmutedDeriveMap do
  @derive {Transmutable, key_map: %{some_key: "someKey"}}
  defstruct [:some_key]
end
