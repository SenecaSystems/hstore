defmodule Hstore.EncoderTest do
  use ExUnit.Case, async: true


  test "it can encode a map" do
    input_map = Hstore.Encoder.encode %{"name" => "Frank", "bubbles" => "seven"}
    # Elixir always sorts map keys alphabetically. Which is cool :|
    assert input_map == ~s("bubbles"=>"seven","name"=>"Frank")
  end

  test "it can encode with nils and booleans" do
    input_map = Hstore.Encoder.encode(%{
      "limit" => nil,
      "chillin"=> true,
      "fratty"=> false
    })
    assert input_map == ~s("chillin"=>"true","fratty"=>"false","limit"=>NULL)
  end

  test "it can encode integers and floats" do
    input_map = Hstore.Encoder.encode %{
      "bubbles" => 7,
      "fragmentation grenades" => 3.5
    }
    assert input_map == ~s("bubbles"=>"7","fragmentation grenades"=>"3.5")
  end

end
