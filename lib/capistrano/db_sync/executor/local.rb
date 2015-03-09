require "fileutils"

module Capistrano::DBSync
  module Executor
    class Local < Base
      def initialize(cap, config)
        super(cap, config, :local)
        load_db_config!(File.read File.join("config", "database.yml"))
      end

      def restore!(dump_dir)
        importer(dump_dir).restore(jobs: config[:local][:pg_jobs]).each do |cmd|
          cap.info "Running locally: #{cmd}"
          system(cmd)
        end

        cap.info "Completed database restore."
      ensure
        clean_dump_if_needed!(dump_dir)
      end

      private

      def clean_dump_if_needed!(dump_dir)
        if cleanup?
          FileUtils.rm_rf dump_dir
          cap.info "Removed #{dump_dir} locally."
        else
          cap.info "Leaving #{dump_dir} locally. Use \"local: { cleanup: true }\" to remove."
        end
      end

      def importer(dump_dir)
        Postgres::Importer.new(dump_dir, db_config)
      end
    end
  end
end
