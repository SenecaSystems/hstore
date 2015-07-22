Hstore
======

HStore support for Postgrex

```elixir
  def deps do
    [{:hstore, "~> 0.0.2"}]
  end
```

Now all up in your `iex -S mix`:
```elixir
  opts = [
    hostname: "localhost",
    username: "postgres",
    database: "hstore_database",
    encoder: &Hstore.encoder/3,
    decoder: &Hstore.decoder/4,
    formatter: &Hstore.formatter/1
  ]
  {:ok, pid} = Postgrex.Connection.start_link(opts)
  Postgrex.Connection.query(pid, "SELECT * FROM table_with_hstore", [])
```
