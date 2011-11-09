namespace :couchdb do
  task :migrate => :environment do
    migration_files = Dir[Rails.root.join('db/migrate/*.rb')]
    migration_files_by_id = Hash[*migration_files.map {|path| [migration_number_from_file(path), path] }.flatten]
    applied_migration_ids = SchemaMigration.all.map(&:id)
    migration_ids_to_apply = migration_files_by_id.except(*applied_migration_ids).sort
    if migration_ids_to_apply.empty?
      puts "DB already up to date."
    else
      puts "Will apply migrations: #{migration_ids_to_apply.map(&:first).to_sentence}"
      migration_ids_to_apply.each do |migration_id, path|
        puts "Applying #{path}..."
        start_time = Time.now
        load path
        seconds = Time.now - start_time
        SchemaMigration.create!(:_id => migration_id, :file => path, :applied => Time.now, :seconds_elapsed => seconds)
        puts "         ...finished in #{seconds} seconds."
      end
      puts "DB migrated."
    end
  end
end

def migration_number_from_file(path)
  path.match(/db\/migrate\/(\d+)_.+\.rb/)[1]
end
