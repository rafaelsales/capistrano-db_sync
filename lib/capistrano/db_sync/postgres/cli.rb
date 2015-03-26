class Capistrano::DBSync::Postgres::CLI
  def initialize(config)
    @config = config
  end

  def dump(to_file, db, options = [])
    args = to_string_args(options)
    "#{with_pw} pg_dump #{credentials} #{format_args} -f #{to_file} #{args} #{db}".strip
  end

  def restore(from_file, db, options = [])
    args = to_string_args(options)
    "#{with_pw} pg_restore #{credentials} #{format_args} -d #{db} #{args} #{from_file}".strip
  end

  def drop_db(db)
    psql %Q|DROP DATABASE IF EXISTS "#{db}";|
  end

  def create_db(db)
    psql %Q|CREATE DATABASE "#{db}";|
  end

  def rename_db(old_db, new_db)
    psql %Q|ALTER DATABASE "#{old_db}" RENAME TO "#{new_db}";|
  end

  def psql(command, db = "postgres")
    normalized_command = command.gsub('"', '\"').gsub(/\s\s+|\n/, " ")
    %Q|#{with_pw} psql #{credentials} -d #{db} -c "#{normalized_command}"|.strip
  end

  def kill_processes_for_db(db)
    psql <<-SQL.gsub("$", "\\$")
      SELECT pg_terminate_backend(pg_stat_activity.pid)
        FROM pg_stat_activity
       WHERE pg_stat_activity.datname = $$#{db}$$
         AND pid <> pg_backend_pid();
    SQL
  end

  def copy_and_compress_to_file(to_compressed_file, db, query)
    psql "\\copy (#{query}) TO PROGRAM 'gzip > #{to_compressed_file}' WITH CSV", db
  end

  def copy_from_compressed_file(from_compressed_file, db, table)
    psql "\\copy #{table} FROM PROGRAM 'gunzip --to-stdout #{from_compressed_file}' WITH CSV", db
  end

  private

  def format_args
    "--no-acl --no-owner --format=custom"
  end

  def credentials
    credentials_params = []
    credentials_params << "-U #{config['username']}" unless config.fetch('username', '').empty?
    credentials_params << "-h #{config['host']}"     unless config.fetch('host', '').empty?
    credentials_params << "-p #{config['port']}"     unless config.fetch('port', '').empty?
    credentials_params.join(" ")
  end

  def with_pw
    if config['password']
      "PGPASSWORD='#{config['password']}'"
    end
  end

  def to_string_args(options)
    options.nil? ? "" : options.join(" ")
  end

  attr_reader :config, :session_id
end
