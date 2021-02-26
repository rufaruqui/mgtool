require './initialize.rb'
 
#require 'delayed_job_active_record'

desc 'Importing the table'
task :import_table, [:table_name]  do |t, args|
   ImportSingleTable.perform args.table_name.to_sym
end

 
desc "Import all tables"

task :import_all_tables do 
   
   ImportSingleTable.import_all
   
   PGDB.extension :pg_json
   mod = PGDB[:ImportFiles].where(:Name=>"SCF-FINSURE-JAN199MODIFIED).xls").first[:MessageContent]
   mod["commissionMonth"] =  "January 19"   unless mod.nil?
   mod["commissionDate"]  =  "2019-01-01"   unless mod.nil?
   PGDB[:ImportFiles].where(:Name=>"SCF-FINSURE-JAN199MODIFIED).xls").update(MessageContent: mod) unless mod.nil?
 
end


desc "Insert data into elastic search"

task :insert_into_es  do  
 SearchClient.insert_all
end

desc "Import all data from MySQL and insert into PG and Elastic Search"

task :import_all_and_insert_into_es =>[:import_all_tables, :insert_into_es] do
   puts "Imported and then inserted all data into PG and ES".blue
end





######
### ds = PGDB[:ImportFiles]
### ds.first[:MessageContent].each { |item| ap item }