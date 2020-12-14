require 'securerandom'

class DbService
      @@MysqlDB = Sequel.connect(AppConfig.get["MYSQL"])
      @@PgDB = Sequel.connect(AppConfig.get["PG"])

    def self.connect(options={})
        @@MysqlDB
    end

    def self.mysql_connect(options={})
        @@MysqlDB
    end
    
    def self.pg_connect(options={})
        @@PgDB
        #@@PgDB = Sequel.connect(AppConfig.get[options[:DB]]) unless options.blank?
    end

    def self.rpg_connect(options={})
     Sequel.connect(AppConfig.get["PG"])
    end
    
     def self.insert_row row, broker_id
       if row[:OrganizationUserId].nil? or row[:TemplateId].nil? or row[:OrganizationUserId] == 0 or row[:TemplateId] == 0
            puts "#{row[:MessageContent][:broker]} -- Ignoring : broker or template doesn't exist".yellow
            MyLogger.warn "#{row[:MessageContent][:broker]} -- Ignoring : broker or template doesn't exist"
            puts  "BrokerId:#{broker_id}, BrokerName: #{BrokerHash[broker_id]} -- missing in the new system".red if broker_id
            MyLogger.warn "BrokerId:#{broker_id}, BrokerName: #{BrokerHash[broker_id]} -- missing in the new system" if broker_id
            return 
        end
          #insert_into_rails_pg row
          insert_row_into_abp_table row
      end


    def self.insert_into_rails_pg row
        
            
      PGDB[:ImportFiles] 
         .insert_conflict
         .insert(
            :Name=>row[:Name],
            :FileKey=>row[:FileKey],
            :OrganizationUserId=>row[:OrganizationUserId],
            :TemplateId=>row[:TemplateId],
            :FileType => row[:FileType],
            :MessageContent=>row[:MessageContent].to_json, 
            :created_at=>Time.now, 
            :updated_at=>Time.now
            )
    end

   def on_exit
     @@MysqlDB.disconnect
     @@PgDB.disconnect
   end
   
   


   def self.insert_row_into_abp_table row
       
      PGDB[:ImportFiles] 
         .insert_conflict
         .insert(
            :CreationTime => Time.now,
            :CreatorUserId => 1,
            :IsDeleted => false, 
                    :Name => row[:Name],
      :OrganizationUserId => row[:OrganizationUserId],
              :TemplateId => row[:TemplateId].to_json, 
                :FileType => row[:FileType],
                  :Status => 0,
            :IsSyncNeeded => false,
          :MessageContent => row[:MessageContent].to_json,
                   :Error => [].to_json,
                 :FileKey => row[:FileKey]
         )
   end
end




# {
#                       :Id => 135,
#             :CreationTime => 2020-12-04 17:18:29.770412 +0600,
#            :CreatorUserId => 47,
#     :LastModificationTime => nil,
#       :LastModifierUserId => nil,
#                :IsDeleted => false,
#            :DeleterUserId => nil,
#             :DeletionTime => nil,
#                     :Name => "TST_PLAN_97_20201204051821000.xls",
#       :OrganizationUserId => 45,
#               :TemplateId => 97,
#                 :FileType => 2,
#                   :Status => 0,
#             :IsSyncNeeded => false,
#           :MessageContent => "{\"Contents\":[],\"Errors\":[],\"HasCriticalError\":false,\"IsProtected\":false,\"VariationDetected\":false,\"BrokerOrgUserId\":45,\"ImportDate\":\"2020-12-04T17:18:29.7667272+11:00\",\"Broker\":\"TST\",\"Aggregator\":\"PLAN\",\"CommissionMonth\":\"December 2020\",\"Silo\":\"TPS\",\"Book\":\"Plan\",\"StageOfLife\":\"Runoff\"}",
#                    :Error => "[]",
#                  :FileKey => "0zFnMq1pECrqjjht+xngrXOe9OWv2RPq7SryQLfxtc8="
# }