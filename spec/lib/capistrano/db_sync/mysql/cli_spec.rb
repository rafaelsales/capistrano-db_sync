require 'spec_helper'

describe Capistrano::DBSync::MySQL::CLI do
  let(:config) do
    {
      "database" => "staging",
      "username" => "user",
      "password" => "pw",
      "adapter"  => "mysql",
      "host"     => "127.0.0.1",
      "port"     => "3306",
    }
  end

  let(:cli) { Capistrano::DBSync::MySQL::CLI.new(config) }

  describe "#dump" do
    it "generates pg_dump command" do
      command = cli.dump("/tmp/staging.dump", "staging", ["--section=pre-data"])
      command.must_equal "mysqldump -u user -p pw -h 127.0.0.1 -P 3306 --lock-tables=false --section=pre-data staging > /tmp/staging.dump"
    end
  end

  describe "#restore" do
    it "generates pg_dump command" do
      command = cli.restore("/db/production.dump", "staging")
      command.must_equal "mysql -u user -p pw -h 127.0.0.1 -P 3306  -D staging < /db/production.dump"
    end
  end
end
