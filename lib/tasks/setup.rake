desc "Create CouchDB databases and populate with seed data."
task :setup => %w( couchdb:create db:seed )
