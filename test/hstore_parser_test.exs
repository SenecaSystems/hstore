defmodule HstoreParserTest do
  use ExUnit.Case

  test "it can decode into a map" do
    result_map = Hstore.Parser.decode ~s("name"=>"Frank","bubbles"=>"seven")
    assert result_map == %{"name" => "Frank", "bubbles" => "seven"}
  end

  test "it can decode special values" do
    result_map = Hstore.Parser.decode ~s("limit"=>NULL,"chillin"=>"true","fratty"=>"false")
    assert result_map == %{
      "limit" => nil,
      "chillin"=> true,
      "fratty"=> false
    }
  end

  test "it can decode integers" do
    result_map = Hstore.Parser.decode ~s("bubbles"=>"7")
    assert result_map == %{"bubbles" => 7}
  end
end
