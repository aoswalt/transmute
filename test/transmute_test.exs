defmodule TransmuteTest do
  use ExUnit.Case
  doctest Transmute

  test "map_keys runs a function for each key of a map" do
      start_map = %{"someKey" => 1, "otherKey" => 2}
      expected_map = %{"SOMEKEY" => 1, "OTHERKEY" => 2}
      assert Transmute.map_keys(start_map, &String.upcase/1) == expected_map

      start_map = %{some_key: 1, other_key: 2}
      atom_to_caps = &(&1 |> Atom.to_string() |> String.upcase())
      expected_map = %{"SOME_KEY" => 1, "OTHER_KEY" => 2}
      assert Transmute.map_keys(start_map, atom_to_caps) == expected_map
  end
end
