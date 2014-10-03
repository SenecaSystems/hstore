defmodule Hstore do
  alias Postgrex.TypeInfo

  # passes in (TypeInfo, format, default, binary)
  def decoder(%TypeInfo{sender: "hstore"}, _, _, <<(number_of_pairs::size(32)), (rest::binary)>>) do
    decode_hstore_pairs(number_of_pairs, %{}, rest)
  end

  def decoder(%TypeInfo{}, _format, default, bin) do
    default.(bin)
  end

  def encoder(%TypeInfo{sender: "hstore"}, _, value) do
    number_of_pairs = map_size(value)
    << number_of_pairs::size(32) >> <> hstore_binary_encoding(value)
  end

  # If it is not sent by hstore, default that homie!
  def encoder(%TypeInfo{}, default, value) do
    default.(value)
  end

  def formatter(%TypeInfo{sender: "hstore"}), do: :text
  def formatter(%TypeInfo{}), do: nil

  defp hstore_binary_encoding(dict) do
    Enum.reduce dict, "", fn ({key, value}, full_encoding) ->
      case key do
        # Check for nil keys, which hstore does not accept
        key when is_nil(key) -> raise "`nil` cannot be used as an Hstore key"
        key ->
          key = to_string(key)
          # NULL is represented as <<-1::size(32)>>
          value = if is_nil(value), do: <<-1::size(32)>>, else: to_string(value)
          # each value is comprised of its length followed by the value
          this_encoding = << byte_size(key)::size(32) >> <> key <>
                          << byte_size(value)::size(32) >> <> value
          full_encoding <> this_encoding
      end
    end

  end

  def decode_hstore_pairs(0, acc, _binary) do
    acc
  end

  def decode_hstore_pairs(number_of_pairs, acc, bin) do
    <<(key_size::size(32)), (key::binary-size(key_size)), (rest::binary)>> = bin
    <<(value_size::size(32)), (value::binary-size(value_size)), (rest::binary)>> = rest
    decode_hstore_pairs(number_of_pairs - 1, Dict.put(acc, key, value), rest)
  end

end
