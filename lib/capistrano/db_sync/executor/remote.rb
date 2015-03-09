module Capistrano::DBSync
  module Executor
    class Remote < Base
      def initialize(cap, config)
        super(cap, config, :remote)
        load_db_config! cap.capture("cat #{File.join cap.current_path, 'config', 'database.yml'}")
      end

      # Returns the dump directory location that was downloaded to local
      # machine, which is based on +local_working_dir+.
      def dump_and_download_to!(local_working_dir)
        dump!
        download_to!(local_working_dir)
      ensure
        clean_dump_if_needed!
      end

      private

      def dump!
        cap.execute "mkdir -p #{dump_dir}"

        exporter.dump(data_selection: config[:data_selection]).each do |cmd|
          cap.execute cmd
        end
      end

      def download_to!(local_working_dir)
        system "mkdir -p #{local_working_dir}"
        cap.download! dump_dir, local_working_dir, recursive: true

        cap.info "Completed database dump and download."
        File.join(local_working_dir, File.basename(dump_dir))
      end

      def clean_dump_if_needed!
        if cleanup?
          cap.execute "rm -rf #{dump_dir}"
          cap.info "Removed #{dump_dir} from the server."
        else
          cap.info "Leaving #{dump_dir} on the server. Use \"remote: { cleanup: true}\" to remove."
        end
      end

      private

      def exporter
        Postgres::Exporter.new(dump_dir, db_config)
      end

      def dump_dir
        File.join(working_dir, "dump_#{session_id}_#{db_config['database']}")
      end
    end
  end
end
