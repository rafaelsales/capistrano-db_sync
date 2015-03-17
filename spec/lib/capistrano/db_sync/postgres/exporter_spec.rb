require 'spec_helper'

describe Capistrano::DBSync::Postgres::Exporter do
  let(:working_dir) { "/tmp/dumps/" }
  let(:config)      { { "database" => "faceburger_production", "host" => "10.20.30.40" } }
  let(:exporter)    { Capistrano::DBSync::Postgres::Exporter.new(working_dir, config) }

  describe "#dump" do
    let(:data_selection) do
      {
        posts:    "SELECT * FROM posts WHERE date > NOW() - interval '160 days'",
        comments: "SELECT * FROM comments  WHERE created_at > NOW() - interval '160 days'",
        likes: nil
      }
    end

    it "restore dump files" do
      commands = exporter.dump(data_selection: data_selection)

      # Assert dumping database schema with data except for tables specified on data_selection
      commands[0].must_match /pg_dump.* -f \/tmp\/dumps\/0001-faceburger_production\.schema/
      commands[0].must_match /--exclude-table-data="posts"/
      commands[0].must_match /--exclude-table-data="comments"/
      commands[0].must_match /--exclude-table-data="likes"/

      # Assert dumping data for tables specified on data_selection
      commands[1].must_match /copy.*posts.*\/tmp\/dumps\/0002-posts\.table/
      commands[2].must_match /copy.*comments.*\/tmp\/dumps\/0003-comments\.table/
    end
  end
end
