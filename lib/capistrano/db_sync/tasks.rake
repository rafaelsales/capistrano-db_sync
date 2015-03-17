require "capistrano"
require "capistrano/version"

namespace :db_sync do
  desc <<-DESC
    Synchronize your local database using remote database data.
    Usage: $ cap <stage> db:pull
  DESC

  task :import do
    config = Capistrano::DBSync::Configuration.new(self)

    if config.data_sync_confirmed?
      on roles(:db, primary: true) do
        local = Capistrano::DBSync::Executor::Local.new(self, config)
        remote = Capistrano::DBSync::Executor::Remote.new(self, config)

        downloaded_dir = remote.dump_and_download_to! config[:local][:working_dir]

        local.restore!(downloaded_dir)
      end
    end
  end
end
