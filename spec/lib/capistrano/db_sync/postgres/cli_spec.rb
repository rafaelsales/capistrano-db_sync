require 'spec_helper'

describe Capistrano::DBSync::Postgres::CLI do
  let(:config) do
    {
      "database" => "staging",
      "username" => "user",
      "password" => "pw",
      "adapter"  => "postgresql",
      "host"     => "127.0.0.1",
      "port"     => "5432",
    }
  end

  let(:cli) { Capistrano::DBSync::Postgres::CLI.new(config) }

  describe "#dump" do
    it "generates pg_dump command" do
      command = cli.dump("/tmp/staging.dump", "staging", ["--section=pre-data"])
      command.must_equal "PGPASSWORD='pw' pg_dump -U user -h 127.0.0.1 -p 5432 --no-acl --no-owner --format=custom -f /tmp/staging.dump --section=pre-data staging"
    end
  end

  describe "#restore" do
    it "generates pg_dump command" do
      command = cli.restore("/db/production.dump", "staging", ["--jobs=3"])
      command.must_equal "PGPASSWORD='pw' pg_restore -U user -h 127.0.0.1 -p 5432 --no-acl --no-owner --format=custom -d staging --jobs=3 /db/production.dump"
    end
  end

  describe "#psql" do
    it "generates a command to drop a database" do
      command = cli.psql("fake command")
      command.must_equal %Q{PGPASSWORD='pw' psql -U user -h 127.0.0.1 -p 5432 -d postgres -c "fake command"}
    end
  end

  describe "#drop_db" do
    it "generates a command to drop a database" do
      command = cli.drop_db("staging")
      command.must_match /psql .* -c "DROP DATABASE IF EXISTS \\"staging\\";"/
    end
  end

  describe "#create_db" do
    it "generates a database creation command" do
      command = cli.create_db("staging")
      command.must_match /psql .* -c "CREATE DATABASE \\"staging\\";"/
    end
  end

  describe "#rename_db" do
    it "generates a database creation command" do
      command = cli.rename_db("staging_old", "staging_new")
      command.must_match /psql .* -c "ALTER DATABASE \\"staging_old\\" RENAME TO \\"staging_new\\";"/
    end
  end
end
