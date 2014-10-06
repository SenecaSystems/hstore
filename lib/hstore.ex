defmodule Hstore do
  alias Postgrex.TypeInfo
  alias Hstore.Decoder
  alias Hstore.Encoder

  @hstore_type %TypeInfo{sender: "hstore", type: "hstore"}

  # passes in (TypeInfo, format, default, binary)
  def decoder(@hstore_type, _format, _default, bin) do
    Decoder.decode bin
  end

  def decoder(%TypeInfo{}, _format, default, bin) do
    default.(bin)
  end

  def encoder(@hstore_type, _, nil) do
    nil
  end

  def encoder(@hstore_type, _, value) do
    Encoder.encode value
  end

  # If it is not sent by hstore, default that homie!
  def encoder(%TypeInfo{}, default, value) do
    default.(value)
  end

  def formatter(%TypeInfo{sender: "hstore"}), do: :text
  def formatter(%TypeInfo{}), do: nil

end
