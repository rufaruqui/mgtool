
require 'yaml'
require 'pp'
require 'sequel'
require 'inifile' 
require 'date'
require 'awesome_print' 
require 'colorize'
require 'logger'
require 'base64'
require 'set'

require_relative 'lib/app_config.rb'
require_relative 'lib/db_service.rb'
require_relative 'lib/import_key_map.rb'
require_relative 'lib/process_single_import_file.rb' 
require_relative 'lib/process_pg_and_es_row.rb'  
require_relative 'lib/import_single_table.rb'
require_relative 'lib/search_client.rb'
require_relative  'lib/get_broker_map.rb'


MyLogger = Logger.new(File.open('mgtool.log', File::WRONLY | File::APPEND | File::CREAT))



### Connect with PG and MySQL servers##
MSDB = DbService.connect
PGDB = DbService.pg_connect 
#RADIAL_PG = DbService.rpg_connect 



### Create a Broker Hash -- mapping new system with the old one ####
BrokerMap = GetBrokerMap.get_broker_map
bh = Hash.new
MSDB[:Broker].to_a.each { |b| bh[b[:Broker_ID]] = b[:Broker_Name] }
BrokerHash = bh



ManufacturerHash = GetBrokerMap.get_manufacturer_reference
ManufacturerHash[:wba] = "Auswide Bank (AWB)"
ManufacturerHash[:firstmac] = "Firstmac (FM)"
ManufacturerHash[:"homeside lending (now part of nab) (hsl)"] = "HomeSide Lending(HSL)"
ManufacturerHash[:"auswide bank"] = "Auswide Bank (AWB)"
ManufacturerHash[:tnt] = "Firstmac (FM)"
ManufacturerHash[:"my state"] = "My State (MST)"
ManufacturerHash[:fmc] = "Firstmac (FM)"
ManufacturerHash[ :"auswide bank ltd"] = "Auswide Bank (AWB)"

CommType  = Hash.new;  

["TC", "Trail Commissions", "Trail", "TRAIL", "Home Loan - Trailing", "New Facility", "Trails", "Trail Commission", "Broker Trail - 100%", "Broker Trail - 95%", "Broker Trail - 90%", "Allianz", "Trail with Deduction Payment", "Trail Data"].each do |item| 
    CommType[item.downcase.to_sym] = "TC"
end

["UC", "UPFRONT", "Upfront", "UFC", "Upfront Commissions", "Home Loan - Upfront", "Home Loan", "Deposit Guarantee", "Insurance", "Commercial", "Personal Loan", "Broker Upfront - 100%", "Broker Upfront - 95%", "Broker Upfront- 90%", "Upfronts", "Upfront Data"].each do |item| 
    CommType[item.downcase.to_sym] = "UC"
end

["DI", "DIS", "Home Loan - Discharge", "Home Loan - Discharge Approximate"].each do |item| 
    CommType[item.downcase.to_sym] = "DI"
end

["AR", "ARR", "Arrears", "Home Loan - Arrears", "Paid Out"].each do |item| 
    CommType[item.downcase.to_sym] = "AR"
end

CommType["Clawback".downcase.to_sym] = "CB"
CommType["Referrer upfront".downcase.to_sym] = "RU"
CommType["Referrer Upfront Deductions".downcase.to_sym] = "RU"
CommType["Broker Upfront Deductions".downcase.to_sym] = "RU"



CommType["Referrer Trail".downcase.to_sym] = "RT"
CommType["Referrer Trail Deductions".downcase.to_sym] = "RT"
CommType["Broker Trail Deductions".downcase.to_sym] = "RT"

CommType[:""]="TC"

