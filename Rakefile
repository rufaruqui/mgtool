require './initialize.rb'
 
#require 'delayed_job_active_record'

desc 'Importing the table'
task :import_table, [:table_name]  do |t, args|
   ImportSingleTable.perform args.table_name.to_sym
end

 
desc "Import all tables"

task :import_all_tables do 
   ImportSingleTable.import_all
end


desc "Insert data into elastic search"

task :insert_into_es  do 
 SearchClient.insert_all
end

desc "Import all data from MySQL and insert into PG and Elastic Search"

task :import_all_and_insert_into_es =>[:import_all_tables, :insert_into_es] do
   puts "Imported and then inserted all data into PG and ES".blue
end

