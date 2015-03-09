require 'spec_helper'

describe Capistrano::DBSync::Postgres::Exporter do
  let(:working_dir) { "/tmp/dumps/" }
  let(:config)      { { "database" => "faceburger_production", "host" => "10.20.30.40" } }
  let(:exporter)    { Capistrano::DBSync::Postgres::Exporter.new(working_dir, config) }

  describe "#dump" do
    let(:data_selection) do
      {
        campaigns:   "SELECT * FROM campaigns WHERE date > NOW() - interval '160 days'",
        keywords:    "SELECT * FROM keywords  WHERE created_at > NOW() - interval '160 days'",
        phone_calls: nil
      }
    end

    it "restore dump files" do
      commands = exporter.dump(data_selection: data_selection)

      # Assert dumping database schema with data except for tables specified on data_selection
      commands[0].must_match /pg_dump.* -f \/tmp\/dumps\/0001-faceburger_production\.schema/
      commands[0].must_match /--exclude-table-data="campaigns"/
      commands[0].must_match /--exclude-table-data="keywords"/
      commands[0].must_match /--exclude-table-data="phone_calls"/

      # Assert dumping data for tables specified on data_selection
      commands[1].must_match /COPY.*campaigns.*\/tmp\/dumps\/0002-campaigns\.table/
      commands[2].must_match /COPY.*keywords.*\/tmp\/dumps\/0003-keywords\.table/
    end
  end
end
