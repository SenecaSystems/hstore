defmodule Hstore.Ecto do
  alias Postgrex.TypeInfo
  alias Hstore.Decoder
  alias Hstore.Encoder

  @hstore_type %TypeInfo{sender: "hstore", type: "hstore"}

  def decoder(@hstore_type, _format, _default, bin) do
    Apex.ap("Decoder with hstore")
    Decoder.decode bin
  end

  def decoder(%TypeInfo{} = type_info, format, default, bin) do
    Apex.ap("Falling back to Ecto decoder")
    Ecto.Adapters.Postgres.decoder(type_info, format, default, bin)
  end

  def encoder(@hstore_type, _default, nil) do
    nil
  end

  def encoder(@hstore_type, _default, value) do
    Encoder.encode value
  end

  def encoder(%TypeInfo{} = type_info, default, value) do
    Ecto.Adapters.Postgres.encoder(type_info, default, value)
  end

  def formatter(%TypeInfo{sender: "hstore"}), do: :text
  def formatter(type_info), do: Ecto.Adapters.Postgres.formatter(type_info)

end
