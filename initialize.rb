
require 'yaml'
require 'pp'
require 'sequel'
require 'inifile' 
require 'date'
require 'awesome_print' 
require 'colorize'
require 'logger'
require 'base64'

require_relative 'lib/app_config.rb'
require_relative 'lib/db_service.rb'
require_relative 'lib/import_key_map.rb'
require_relative 'lib/process_single_import_file.rb' 
require_relative 'lib/process_pg_and_es_row.rb'  
require_relative 'lib/import_single_table.rb'
require_relative 'lib/search_client.rb'
require_relative  'lib/get_broker_map.rb'


MSDB = DbService.connect
PGDB = DbService.pg_connect 
RADIAL_PG = DbService.rpg_connect 
BrokerMap = GetBrokerMap.get_broker_map


MyLogger = Logger.new(File.open('mgtool.log', File::WRONLY | File::APPEND | File::CREAT))

bh = Hash.new
MSDB[:Broker].to_a.each { |b| bh[b[:Broker_ID]] = b[:Broker_Name] }
BrokerHash = bh
ManufacturerHash = GetBrokerMap.get_manufacturer_reference
