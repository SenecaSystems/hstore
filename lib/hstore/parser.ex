defmodule Hstore.Parser do

  ## Full credit for decoding goes to the pg-hstore ruby gem:
  # https://github.com/seamusabshere/pg-hstore/blob/master/lib/pg_hstore.rb

  # Punctuation
  @single_quote "'"
  @e_single_quote "E'"
  @double_quote "\""
  @hashrocket "=>"
  @comma ","
  @slash "\\"

  # Types
  @integer ~r/\A\d+\z/
  @float ~r/\A\d+\.\d+\z/

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

  def decode(bin) do
    Enum.reduce Regex.scan(@pair, bin), %{}, fn ([_raw, key, value], result_map) ->
      Dict.put(result_map, parse_key(key), parse_value(value))
    end
  end

  defp parse_key(key) do
    unescape un_double_quote key
  end

  defp parse_value(value) do
    if Regex.match?(@null, value) do
      nil
    else
      replace_constant(unescape(un_double_quote(value)))
    end
  end

  def un_double_quote(value) do
    if Regex.match?(@double_quoted_string, value) do
      Regex.replace(@double_quoted_string, value, "\\1")
    else
      value
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
    parse_types Regex.replace(@escaped_char, value, "\\1")
  end

  defp parse_types(value) do
    cond do
      Regex.match?(@integer, value) ->
        String.to_integer(value)
      Regex.match?(@float, value) ->
        String.to_float(value)
      true ->
        value
    end
  end
end
