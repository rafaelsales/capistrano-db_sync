module Capistrano
  module DBSync
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "/db_sync/**/*.rb")).sort.each { |f| require f }
load File.join(File.dirname(__FILE__), "/db_sync/tasks.rake")
