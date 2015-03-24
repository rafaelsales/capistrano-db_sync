class Capistrano::DBSync::MySQL::CLI
  def initialize(config)
    @config = config
  end

  def dump(to_file, db, options = [])
    args = to_string_args(options)
    "mysqldump #{credentials} --lock-tables=false #{args} #{db} > #{to_file}"
  end

  def restore(from_file, db, options = [])
    args = to_string_args(options)
    "mysql #{credentials} #{args} -D #{db} < #{from_file}"
  end

  def drop_db(db)
    mysql %Q|DROP DATABASE IF EXISTS "#{db}";|
  end

  def create_db(db)
    mysql %Q|CREATE DATABASE "#{db}";|
  end

  def rename_db(old_db, new_db)
    mysql %Q|ALTER DATABASE "#{old_db}" RENAME TO "#{new_db}";|
  end

  def mysql(command, db = nil)
    db_argument = "-D #{db}" if db
    normalized_command = command.gsub('"', '\"').gsub(/\s\s+|\n/, " ")
    "mysql #{credentials} #{args} #{db_argument} -e #{normalized_command}"
  end

  private

  def credentials
    params = []
    params << "-u #{config['username']}" unless config.fetch('username', '').empty?
    params << "-p #{config['password']}" unless config.fetch('password', '').empty?
    params << "-h #{config['host']}"     unless config.fetch('host', '').empty?
    params << "-P #{config['port']}"     unless config.fetch('port', '').empty?
    params << "-S #{config['socket']}"   unless config.fetch('socket', '').empty?
    params.join(" ")
  end

  def to_string_args(options)
    options.nil? ? "" : options.join(" ")
  end

  attr_reader :config, :session_id
end
