defmodule HstoreTest do
  use ExUnit.Case, async: true

  test "speedy thing goes in, speedy thing comes out" do
    test_map = %{
      "YOLO" => false,
      "unresolved failures" => 3,
      "chrysalis spun" => 4.2213,
      "Santa Claus" => "The best wrapper alive",
      "the limit" => nil
    }

    assert test_map == (Hstore.Encoder.encode(test_map) |> Hstore.Decoder.decode)
  end
end
