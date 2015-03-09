module Capistrano::DBSync
  module Executor
    class Base

      # +side+ must be :local or :remote
      def initialize(cap, config, side)
        @cap        = cap
        @config     = config
        @session_id = Time.now.strftime("%Y-%m-%d-%H%M%S")
        @side       = side
      end

      def working_dir
        File.join config[side][:working_dir]
      end

      def env
        config[side][:env].to_s
      end

      def cleanup?
        config[side][:cleanup]
      end

      private

      def load_db_config!(config_file_contents)
        yaml = YAML.load(ERB.new(config_file_contents).result)
        @db_config = yaml[env].tap { |db_config| Postgres.validate!(db_config) }
      end

      attr_reader :cap, :config, :db_config, :side, :session_id
    end
  end
end
