module Capistrano::DBSync
  module Postgres
    def self.validate!(config)
      unless %w(postgresql pg).include? config['adapter']
        raise NotImplementedError, "Database adapter #{config['adapter']} is not supported"
      end
    end
  end
end
