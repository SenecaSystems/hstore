defmodule Hstore.EctoTest do
  alias Ecto.Adapters.Postgres

  use ExUnit.Case, async: true


  defmodule EctoTestRepo do
    use Ecto.Repo, adapter: Ecto.Adapters.Postgres

    def conf do
      [
        hostname: "localhost",
        username: "postgres",
        database: "hstore_test",
        encoder: &Hstore.Ecto.encoder/3,
        decoder: &Hstore.Ecto.decoder/4,
        formatter: &Hstore.Ecto.formatter/1
      ]
    end
  end

  defmodule Version do
      use Ecto.Model

    schema "versions" do
      field :old_data, :hstore, default: nil
      field :changes, :hstore, default: %{}
    end
  end

  setup do
    EctoTestRepo.start_link
    Postgres.query(EctoTestRepo, "CREATE TABLE IF NOT EXISTS versions(id serial primary key, old_data hstore, changes hstore)", [])
    :ok
  end

  test "insert hstore object" do
    new_version = %Version{ old_data: %{ dollars: 100, euro: 350 }, changes: %{ dollars: 70 } }
    %Version{id: id} =  EctoTestRepo.insert(new_version)
    database_version = EctoTestRepo.find(id)
    assert database_version.old_data == new_version.old_data
    assert database_version.changes == new_version.changes
  end
end
