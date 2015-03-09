require 'spec_helper'

describe Capistrano::DBSync::Postgres::Importer do
  let(:working_dir) { "/tmp/dumps/" }
  let(:config)      { { "database" => "faceburger_development", "host" => "localhost" } }
  let(:importer)    { Capistrano::DBSync::Postgres::Importer.new(working_dir, config) }

  describe "#restore" do
    before do
      Dir.stubs(:glob).with("/tmp/dumps/*.schema")
        .returns(["/tmp/dumps/0001-faceburger_production.schema"])

      Dir.stubs(:glob).with("/tmp/dumps/*.table")
        .returns(["/tmp/dumps/0002-campaigns.table", "/tmp/dumps/0003-keywords.table"])
    end

    it "restore dump files" do
      commands = importer.restore(jobs: 3)

      # Assert drop and create temporary database
      commands[0].must_match /pg_terminate_backend.*faceburger_development_\d+/m
      commands[1].must_match /DROP DATABASE IF EXISTS.*faceburger_development_\d+/
      commands[2].must_match /CREATE DATABASE.*faceburger_development_\d+/

      # Assert restore schema definition and data of tables with full data
      commands[3].must_match /pg_restore.*--section=pre-data --section=data --jobs=3/
      commands[3].must_match /pg_restore.* \/tmp\/dumps\/0001-faceburger_production\.schema/

      # Assert import selective tables data
      commands[4].must_match /COPY campaigns.*\/tmp\/dumps\/0002-campaigns\.table/
      commands[5].must_match /COPY keywords.*\/tmp\/dumps\/0003-keywords\.table/

      # Assert restore indexes, constraints, triggers and rules
      commands[6].must_match /pg_restore.*--section=post-data --jobs=3/
      commands[6].must_match /pg_restore.* \/tmp\/dumps\/0001-faceburger_production\.schema/

      # Assert rename the temporary database to target restoring database name
      commands[7].must_match /pg_terminate_backend.*faceburger_development/m
      commands[8].must_match /DROP DATABASE IF EXISTS.*faceburger_development/
      commands[9].must_match /ALTER DATABASE.*faceburger_development_\d+.*RENAME TO.*faceburger_development.*/
    end
  end
end
