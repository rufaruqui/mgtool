require './load_lib.rb'
 




pp "All tables in #{AppConfig.get["MYSQL"]["host"]}"
pp MSDB.tables


pp "All tables in #{AppConfig.get["PG"]["host"]}"
pp PGDB.tables

## Extract all import tables
import_tables = MSDB.tables.filter.each { |t| t.to_s.include? "Import_"  }

pp "All Import tables"
pp import_tables

## Calculate total number of rows to be inserted in PG db
toatal_rows = import_tables.inject(0) do |count, table| 
      tmp =MSDB[table.to_sym].select(:File_Name).distinct.count 
      pp "#{tmp.to_s} rows from  #{table.to_s} of #{AppConfig.get["MYSQL"]["host"]} "
      count += tmp
end

pp "Total #{toatal_rows.to_s} rows to be inserted into PG DB"


pp "Processing  all import tables"

# import_tables.each do |table|  
#     # table = :Import_HLS1
#      pp "Extracting unique file names from #{table.to_sym}"
#      ImportSingleTable.perform table
# end


 MSDB.disconnect
 PGDB.disconnect