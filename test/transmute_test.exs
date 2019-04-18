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

  describe "transform" do
    test "map_key specifies how to map each key through Transmute.map_keys" do
      start_map = %{"someKey" => 1, "otherKey" => 2}
      expected_map = %{"SOMEKEY" => 1, "OTHERKEY" => 2}
      assert Transmute.transform(start_map, map_key: &String.upcase/1) == expected_map

      start_map = %{some_key: 1, other_key: 2}
      atom_to_caps = &(&1 |> Atom.to_string() |> String.upcase())
      expected_map = %{"SOME_KEY" => 1, "OTHER_KEY" => 2}
      assert Transmute.transform(start_map, map_key: atom_to_caps) == expected_map
    end

    test "map_shape specifies how to map the shape of the data" do
      start_data = %{"someKey" => 1, "otherKey" => 2}
      expected_data = [{"otherKey", 2}, {"someKey", 1}]
      assert Transmute.transform(start_data, map_shape: &Map.to_list/1) == expected_data

      start_data = %{some_key: 1, other_key: 2}
      expected_data = [other_key: 2, some_key: 1]
      assert Transmute.transform(start_data, map_shape: &Map.to_list/1) == expected_data
    end

    test "key_map sets specific incoming key mappings" do
      start_data = %{this_key: 1, some_key: 2}
      key_map = %{this_key: :that_key}
      expected_data = %{that_key: 1, some_key: 2}
      assert Transmute.transform(start_data, key_map: key_map) == expected_data
    end

    test "keys are mapped before the shape" do
      start_data = %{a: 1}
      map_key = &Atom.to_string/1

      map_shape = fn map ->
        assert %{"a" => _} = map
        Map.to_list(map)
      end

      expected_data = [{"a", 1}]

      assert Transmute.transform(start_data, map_key: map_key, map_shape: map_shape) ==
               expected_data
    end

    test "only keeps a subset of incoming keys" do
      start_data = %{this_key: 1, some_key: 2}
      expected_data = %{this_key: 1}
      assert Transmute.transform(start_data, only: [:this_key]) == expected_data
    end
  end
end
