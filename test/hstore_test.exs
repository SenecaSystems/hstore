defmodule HstoreTest do
  use ExUnit.Case

  test "decoding an encoding is the original value" do
    map = %{"home" => "skillet", "map" => "party"}
    assert map == Hstore.decoder(%Postgrex.TypeInfo{sender: "hstore"}, nil, nil,
      Hstore.encoder(%Postgrex.TypeInfo{sender: "hstore"}, %{}, map))
  end

  test "it encodes numbers as their string representation" do
    map = %{"Bubbles!" => 7}
    assert %{"Bubbles!" => "7"} == Hstore.decoder(%Postgrex.TypeInfo{sender: "hstore"}, nil, nil,
      Hstore.encoder(%Postgrex.TypeInfo{sender: "hstore"}, %{}, map))
  end

  test "encoding begins with the number of pairs" do
    map = %{"one" => "fish", "two" => "fish", "red" => "fish", "blue" => "fish"}
    in_the_database = Hstore.encoder(%Postgrex.TypeInfo{sender: "hstore"}, %{}, map)
    assert <<(4::size(32)), (rest::binary)>> = in_the_database
  end

  test "pair is encoded as length of value folowed by value" do
    map = %{"one" => "fish"}
    assert <<
      0,0,0,1, # number of key/value pairs
      0,0,0,3, # byte size of "one"
      111, 110, 101, # "one"
      0, 0, 0, 4, # byte size of "fish"
      102, 105, 115, 104 # "fish"
    >> == Hstore.encoder(%Postgrex.TypeInfo{sender: "hstore"}, %{}, map)
  end
end
