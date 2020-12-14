require './initialize.rb'
 
#require 'delayed_job_active_record'

desc 'Importing the table'
task :import_table, [:table_name]  do |t, args|
   ImportSingleTable.perform args.table_name.to_sym
end

 
desc "Import all tables"

task :import_all_tables do 
   start = Time.now
   import_tables = MSDB.tables.filter.each { |t| t.to_s.include? "Import_"  }
   import_tables.each do |table|
    puts "Importing rows form #{table.to_s}".red
    MyLogger.info "Importing rows form #{table.to_s}"
    ImportSingleTable.perform table
   end
   
   finish = Time.now

  diff = ((finish - start)/60).round(2)
  puts "Total time to migrate all data: #{diff} minutes".red
  MyLogger.info "Total time to migrate all data: #{diff} minutes"
end


desc "Insert data into elastic search"

task :insert_into_es  do 

    puts "Setting up contents type as nested".red
    MyLogger.info "Setting up contents type as nested"
    SearchClient.put_mapping

    id = (PGDB[:ImportFiles].columns.include? :Id) ? :Id : :id

    puts "Upserting (Update/Insert) total #{PGDB[:ImportFiles].count} entrins from Postgress".yellow

    MyLogger.info "Upserting (Update/Insert) total #{PGDB[:ImportFiles].count} entrins from Postgress"

    PGDB[:ImportFiles].order(id).paged_each do |row| 
        SearchClient.insert_single_row row
    end
end

desc "Import all data from MySQL and insert into PG and Elastic Search"

task :import_all_and_insert_into_es =>[:import_all_tables, :insert_into_es] do
   puts "Imported and then inserted all data into PG and ES".blue
end

