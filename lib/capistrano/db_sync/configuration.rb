require 'active_support/core_ext/hash'

module Capistrano::DBSync
  class Configuration
    extend Forwardable

    DEFAULT_OPTIONS = ->(cap) do
      {
        # Hash mapping a table name to a query or nil in case no data is wanted for a table.
        # E.g.: {
        #   posts:    "SELECT * FROM posts    WHERE created_at > NOW() - interval '60 days'",
        #   comments: "SELECT * FROM comments WHERE created_at > NOW() - interval '30 days'",
        #   likes: nil
        # }
        data_selection: {},

        data_sync_confirmation: true, # Ask for user input confirmation

        local: {
          cleanup: false, # If the downloaded dump directory should be removed after restored

          pg_jobs: 1, # Number of jobs to run in parallel on pg_restore

          working_dir: "./tmp",
          env: ENV.fetch('RAILS_ENV', 'development'),
        },

        remote: {
          cleanup: true, # If the remote dump directory should be removed after downloaded

          working_dir: "/tmp",
          env: cap.fetch(:stage).to_s,
        },
      }
    end

    def initialize(cap_instance = Capistrano.env)
      @cap = cap_instance
      @options = load_options
    end

    def load_options
      user_options = cap.fetch(:db_sync_options)
      DEFAULT_OPTIONS.call(cap).deep_merge(user_options)
    end

    def data_sync_confirmed?
      skip = options[:data_sync_confirmation].to_s.downcase == "false"
      skip || prompt("Confirm replace local database with remote database?")
    end

    def_delegators :@options, :[], :fetch

    private

    attr_reader :cap, :options

    def prompt(message, prompt = "(y)es, (n)o")
      cap.ask(:prompt_answer, "#{message} #{prompt}")
      (cap.fetch(:prompt_answer) =~ /^y|yes$/i) == 0
    end
  end
end
