require 'sequel'
# require 'mysql2'
require 'sqlite3'
Sequel.extension :migration

DB = Sequel.sqlite('./user_config.db')
# DB = Sequel.connect(ENV['CLEARDB_DATABASE_URL'])

Sequel::Migrator.run(DB, './migrations', target: 5, current: 4)