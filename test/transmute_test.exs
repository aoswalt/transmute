defmodule TransmuteTest do
  use ExUnit.Case
  doctest Transmute

  test "greets the world" do
    assert Transmute.hello() == :world
  end
end
