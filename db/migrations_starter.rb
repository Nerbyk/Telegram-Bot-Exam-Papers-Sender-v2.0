require 'sequel'
require 'mysql2'
Sequel.extension :migration

DB = Sequel.connect(ENV['CLEARDB_DATABASE_URL'])

Sequel::Migrator.run(DB, './migrate', target: 3, current: 0)