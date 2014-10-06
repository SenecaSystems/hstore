defmodule Hstore do
  alias Postgrex.TypeInfo

  ## Full credit for decoding goes to the pg-hstore ruby gem:
  # https://github.com/seamusabshere/pg-hstore/blob/master/lib/pg_hstore.rb

  @single_quote "'"
  @e_single_quote "E'"
  @double_quote "\""
  @hashrocket "=>"
  @comma ","
  @slash "\\"

  @escaped_char ~r/\\(.)/
  @escaped_single_quote "\\\'"
  @escaped_double_quote "\\\""
  @escaped_slash "\\\\"
  @double_quoted_string ~r/\A"(.+)"\z/
  @quoted_literal ~r/"[^"\\]*(?:\\.[^"\\]*)*"/
  @unquoted_literal ~r/[^\s=,][^\s=,\\]*(?:\\.[^\s=,\\]*|=[^,>])*/
  @literal ~r/(#{Regex.source(@quoted_literal)}|#{Regex.source(@unquoted_literal)})/
  @pair ~r/#{Regex.source(@literal)}\s*=>\s*#{Regex.source(@literal)}/
  @null ~r/\ANULL\z/

  # passes in (TypeInfo, format, default, binary)
  def decoder(%TypeInfo{sender: "hstore", type: "hstore"} = type_info, _format, _default, bin) do
    Enum.reduce Regex.scan(@pair, bin), %{}, fn ([_raw, key, value], mapp) ->
      real_key = unescape un_double_quote key
      real_value = case Regex.match?(@null, value) do
        true -> nil
        false -> replace_constant(unescape(un_double_quote(value)))
      end
      Dict.put(mapp, real_key, real_value)
    end

  end

  def decoder(%TypeInfo{}, _format, default, bin) do
    default.(bin)
  end

  def un_double_quote(value) do
    case Regex.match?(@double_quoted_string, value) do
      true -> Regex.replace(@double_quoted_string, value, "\\1")
      _ -> value
    end
  end

  def replace_constant("true") do
    true
  end

  def replace_constant("false") do
    false
  end

  def replace_constant(value) do
    value
  end

  def unescape(value) do
    Regex.replace(@escaped_char, value, "\\1")
  end

  def encoder(%TypeInfo{sender: "hstore"}, _, nil) do
    nil
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

end
