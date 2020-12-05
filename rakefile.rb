require './load_lib.rb'
 
#require 'delayed_job_active_record'

desc 'Importing the table'
task :import_table, [:table_name]  do |t, args|
   ImportSingleTable.perform args.table_name.to_sym
end

 
desc "Import all tables"

task :import_all_tables do 
   import_tables = [:Import_AFG1, :Import_CBAB1, :Import_CSC1, :Import_Choice1, :Import_Connective2, :Import_Fast1, :Import_Finsure1, :Import_HLS1, :Import_Iden2, :Import_LKT1, :Import_LMKT1, :Import_Liberty1, :Import_MEZ1, :Import_MMBS1, :Import_OFS1, :Import_Plan2, :Import_RZ1, :Import_Thinktank1, :Import_Vision1, :Import_Vow1, :Import_YBR1, :Import_YBR2, :Import_eChoice1, :Import_nMB1]

   import_tables.each do |table|
    puts "Importing rows form #{table.to_s}".red
    ImportSingleTable.perform table
   end


end


desc "Insert data into elastic search"

task :insert_into_es  do 

    puts "Setting up contents type as nested".red
    SearchClient.put_mapping

    id = (PGDB[:ImportFiles].columns.include? :Id) ? :Id : :id

    puts "Upserting (Update/Insert) total #{PGDB[:ImportFiles].count} entrins from Postgress".yellow
    
    PGDB[:ImportFiles].order(id).paged_each do |row| 
        SearchClient.insert_single_row row
    end
end