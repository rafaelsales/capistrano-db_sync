require 'spec_helper'

describe "Using a regular config" do

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
  end

end


describe "Using a config without a password" do

  describe Capistrano::DBSync::Postgres::CLI do
    let(:config) do
      {
        "database" => "staging",
        "username" => "user",
        "password" => nil,
        "adapter"  => "postgresql",
        "host"     => "127.0.0.1",
        "port"     => "5432",
      }
    end

    let(:cli) { Capistrano::DBSync::Postgres::CLI.new(config) }

    describe "#dump" do
      it "generates pg_dump command" do
        command = cli.dump("/tmp/staging.dump", "staging", ["--section=pre-data"])
        command.must_equal "pg_dump -U user -h 127.0.0.1 -p 5432 --no-acl --no-owner --format=custom -f /tmp/staging.dump --section=pre-data staging"
      end
    end

    describe "#restore" do
      it "generates pg_dump command" do
        command = cli.restore("/db/production.dump", "staging", ["--jobs=3"])
        command.must_equal "pg_restore -U user -h 127.0.0.1 -p 5432 --no-acl --no-owner --format=custom -d staging --jobs=3 /db/production.dump"
      end
    end
  end

end

