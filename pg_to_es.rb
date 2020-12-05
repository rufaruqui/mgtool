 
require './load_lib.rb'
 


pp "All tables in #{AppConfig.get["PG"]["host"]}"
pp PGDB.tables

pp "#{PGDB[:ImportFiles].count.to_s} inserting rows into elastic search" 
PGDB[:ImportFiles].to_a.each do |row| 
    SearchClient.insert_single_row row
end
