
require 'yaml'
require 'pp'
require 'sequel'
require 'inifile' 
require 'date'
require 'awesome_print' 
require 'colorize'

require './classes/app_config.rb'
require './classes/db_service.rb'
require './classes/import_key_map.rb'
require './classes/process_single_import_file.rb' 
require './classes/process_pg_and_es_row.rb'  
require  './classes/import_single_table.rb'
require './classes/search_client.rb'


MSDB = DbService.connect
PGDB = DbService.pg_connect 
RADIAL_PG = DbService.rpg_connect 


### Find out User Org Id for each broker in new system
brokermap = MyCsvReader.csv_to_composite_hash "seeds/broker_user_mappings.csv"

RPGDB = Sequel.connect(AppConfig.get["RPG"])
Sequel[:column].as(:alias)

ds = RPGDB[:AbpUsers].join_table(:inner, :OrganizationUsers, UserId: :Id)
user_org_id_hash = Hash.new
ds.to_a.each { |a| user_org_id_hash[a[:BusinessAbb].downcase.to_sym] = a[:Id] unless a[:BusinessAbb].nil? }


rs = RPGDB[:Aggregators].join_table(:inner, :Templates, AggregatorId: :Id).to_a
aggregator_template_id_hash = Hash.new
rs.to_a.each { |a| aggregator_template_id_hash[a[:ShortName].downcase.to_sym] = a[:Id] unless a[:ShortName].nil? }
RPGDB.disconnect


BrokerMap = brokermap.each do |bm| 
    bm[1][:user_org_id] = user_org_id_hash[bm[1][:business_abbrevation].downcase.to_sym]
    bm[1][:template_id] = aggregator_template_id_hash[bm[1][:aggregator].downcase.to_sym]
end
