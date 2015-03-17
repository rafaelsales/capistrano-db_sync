module Capistrano::DBSync
  class Postgres::Exporter

    # +working_dir+: The location where the dump files will be stored for dump or read for restore.
    # +config+: database configuration hash with following skeleton:
    #           {
    #             "database" => "faceburger_production",
    #             "username" => "fb_prod",
    #             "password" => "BestBurger",
    #             "host"     => "10.20.30.40",
    #             "port"     => "5432"
    #           }
    def initialize(working_dir, config)
      @working_dir = working_dir
      @config      = config
      @cli         = Postgres::CLI.new(config)
    end

    # Returns a set of commands to dump a database with table data selection support.
    #
    # +db+ (optional): Database name to dump
    # +data_selection+ (optional): A hash mapping a table name to a query or nil in
    # case no data is wanted for a table.
    #
    # Example:
    #
    # dump("/tmp/dump",
    #      data_selection:
    #        posts:    "SELECT * FROM posts    WHERE created_at > NOW() - interval '60 days'",
    #        comments: "SELECT * FROM comments WHERE created_at > NOW() - interval '30 days'",
    #        likes: nil
    #      },
    #      db: "faceburger_production")
    #
    # This outputs commands that will generate dump files as:
    #   /tmp/dump/0001-faceburger_production.schema -- will contain db schema and data except
    #                                                  for tables posts, comments and likes
    #   /tmp/dump/0002-posts.table    -- will contain partial data of table posts
    #   /tmp/dump/0003.comments.table -- will contain partial data of table comments
    #
    def dump(db = config["database"], data_selection: {})
      file_namer = Postgres::FileNameGenerator.new(working_dir)
      exclude_tables_args = data_selection.keys.map { |table| %Q|--exclude-table-data="#{table}"| }

      [
        cli.dump(file_namer.next(db, :schema), db, [exclude_tables_args]),
        *dump_partial_selected_data(db, file_namer, data_selection)
      ]
    end

    private

    def dump_partial_selected_data(db, file_namer, data_selection)
      data_selection.map do |table, query|
        cli.copy_and_compress_to_file(file_namer.next(table, :table), db, query) if query
      end.compact
    end

    attr_reader :working_dir, :config, :cli
  end
end
