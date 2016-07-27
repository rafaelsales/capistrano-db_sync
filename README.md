### Capistrano::DBSync

[![Gem Downloads](http://img.shields.io/gem/dt/capistrano-db_sync.svg)](https://rubygems.org/gems/capistrano-db_sync)
[![Build Status](https://snap-ci.com/rafaelsales/capistrano-db_sync/branch/master/build_image)](https://snap-ci.com/heartbits/capistrano-db_sync/branch/master)
[![Code Climate](https://codeclimate.com/github/rafaelsales/capistrano-db_sync/badges/gpa.svg)](https://codeclimate.com/github/heartbits/capistrano-db_sync)
[![GitHub Issues](https://img.shields.io/github/issues/rafaelsales/capistrano-db_sync.svg)](https://github.com/heartbits/capistrano-db_sync/issues)
[![GitHub License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/rafaelsales/capistrano-db_sync)

Fast and sophisticated remote database import using the best of **Postgres 9.2.x**

### Features

* Allows dumping data selectively - choose between entire, partial or no data
* No downtime on restore - it uses a temporary database while restoring
* Uses Postgres parallel restore
* Uses Postgres custom dump format that is automatically compressed
* *MySQL will be supported in near future*

### Requirements

* Capistrano 3.x
* Postgres 9.2.x
* It was tested with Rails only, but it is expected to work in any project containing
  `config/database.yml` file in both local and remote machine.

### Installation

1. Add this line to your application's Gemfile:

   ```ruby
   gem 'capistrano-db_sync', require: false
   ```
   Available in RubyGems: https://rubygems.org/gems/capistrano-db_sync

2. Define your custom settings, if needed. We suggest to put this file at `lib/capistrano/tasks/db_sync.rake`.
   Capistrano 3.x should load all `*.rake` files by default in `Capfile`.
   [See the complete configuration reference](/lib/capistrano/db_sync/configuration.rb)

   ```ruby
   require 'capistrano/db_sync'

   set :db_sync_options, -> do
      {
        # Hash mapping a table name to a query with data selection or nil in case no data
        # is wanted for a table. Tables not listed here will be dumped entirely.
        data_selection: {
          posts:    "SELECT * FROM posts    WHERE created_at > NOW() - interval '60 days'",
          comments: "SELECT * FROM comments WHERE created_at > NOW() - interval '30 days'",
          likes: nil
        },

        local: {
          cleanup: false, # If the downloaded dump directory should be removed after restored
          pg_jobs: 2, # Number of jobs to run in parallel on pg_restore
        },

        remote: {
          cleanup: true, # If the remote dump directory should be removed after downloaded
        }
      }
    end
    ```

### Usage

```sh-session
$ cap production db_sync:import
```

### How it works

The following steps describe what happens when executing `cap production db_sync:import`:

1. SSH into production server with primary db role on capistrano stages configuration
2. Connect to the remote Postgres using credentials of `config/database.yml` in the
   deployed server
3. Dump the database schema, data, triggers, constraints, rules and indexes
4. Download the compressed dump files to local machine
5. Restore the dumps in local machine in following sequence
   1. database schema
   2. data for tables with entire data dumped
   3. data for tables with partial data specified in configuration
   4. triggers, constraints, rules and indexes

### Contributors

* Rafael Sales [@rafaelsales](https://github.com/rafaelsales)
* Jérémy Lecour [@jlecour](https://github.com/jlecour)
* Ankur Agarwal [@devilankur18](https://github.com/devilankur18)

### Plans

* Increase test coverage
* Add support to MySQL
* Validate database versions before applying any changes

### Contributing

1. Fork it ( https://github.com/heartbits/capistrano-db_sync/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
