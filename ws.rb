# # apollo = MysqlService.new.connect
# # tables = apollo.tables
# # import_tables = [:Import_AFG1, :Import_CBAB1, :Import_CSC1, :Import_Choice1, :Import_Connective2, :Import_Fast1, :Import_Finsure1, :Import_HLS1, :Import_Iden2, :Import_LKT1, :Import_LMKT1, :Import_Liberty1, :Import_MEZ1, :Import_MMBS1, :Import_OFS1, :Import_Plan2, :Import_RZ1, :Import_Thinktank1, :Import_Vision1, :Import_Vow1, :Import_YBR1, :Import_YBR2, :Import_eChoice1, :Import_nMB1]

# # afg_keymap= YAML.load_file('docs/afg.yml').symbolize_keys[:Import_AFG1].symbolize_keys

# # filenames = ds[:Import_AFG1].select(:File_Name).distinct

# # filenames.to_a.each { |filename| data_single_upload = ds[:Import_AFG1].where(:File_Name=>filename) }

# # one_row = @conn[:Import_AFG1].pluck(:Broker_ID,:Client,:Account_Number,:Commission,:Commission_Type, :Loan_Amount, :Settlement_Date, :Funder).wh
# # ere(a.first) 

# # data_single_upload.each do |items|
         
# # end

# # #Hard coded lender
# # ImportFile.all.each { |a|  contents=a.contents.each { |d| d.update("lender"=>"CBA")}; a.update(contents: contents) }

# # def fetch_table(table_name, ds)
# #  filenames = ds[table_name.to_sym].select(:File_Name).distinct

# #  filenames.each do |file|
# #     ds[:Import_AFG1].where(:File_Name=>filename)
# #  end
 
# # end



# # # 1	1	Home Loan - Upfront
# # # 2	1	Home Loan - Trailing
# # # 3	1	Home Loan - Discharge
# # # 4	1	Home Loan - Arrears
# # # 5	1	Home Loan - Other
# # # 6	1	Home Loan - Discharge Approximate
# # # 7	2	Insurance - Life


# # Importing all import tables:
# #tab = tables.filter.each { |t| t.to_s.include? "Import_"  }
# # File.open("keymap.json","wb") { |f| tab.each { |t| f.write({"#{t.to_s}": (ImportKeyMap.perform t)}.to_json)}}

#  DB[:Provider].join_table(:inner, :Broker, Provider_ID: :Provider_ID).join_table(:inner, :Client, Client_ID: :Client_ID).join_table(:inn
#  er, :ClientType, ClientType_ID: :ClientType_ID)


#  [ 0] :Id,
# #     [ 1] :CreationTime,
# #     [ 2] :CreatorUserId,
# #     [ 3] :LastModificationTime,
# #     [ 4] :LastModifierUserId,
# #     [ 5] :IsDeleted,
# #     [ 6] :DeleterUserId,
# #     [ 7] :DeletionTime,
# #     [ 8] :AuthenticationSource,
# #     [ 9] :UserName,
# #     [10] :TenantId,
# #     [11] :EmailAddress,
# #     [12] :Name,
# #     [13] :Surname,
# #     [14] :Password,
# #     [15] :EmailConfirmationCode,
# #     [16] :PasswordResetCode,
# #     [17] :LockoutEndDateUtc,
# #     [18] :AccessFailedCount,
# #     [19] :IsLockoutEnabled,
# #     [20] :PhoneNumber,
# #     [21] :IsPhoneNumberConfirmed,
# #     [22] :SecurityStamp,
# #     [23] :IsTwoFactorEnabled,
# #     [24] :IsEmailConfirmed,
# #     [25] :IsActive,
# #     [26] :NormalizedUserName,
# #     [27] :NormalizedEmailAddress,
# #     [28] :ConcurrencyStamp,
# #     [29] :OTP,
# #     [30] :Address,
# #     [31] :PrevPasswords,
# #     [32] :BusinessAbb,
# #     [33] :BusinessName
# # ]

# # [ 0] :Id,
# #     [ 1] :CreationTime,
# #     [ 2] :CreatorUserId,
# #     [ 3] :LastModificationTime,
# #     [ 4] :LastModifierUserId,
# #     [ 5] :IsDeleted,
# #     [ 6] :DeleterUserId,
# #     [ 7] :DeletionTime,
# #     [ 8] :UserId,
# #     [ 9] :RoleId,
# #     [10] :OrganizationUnitId,
# #     [11] :BusinessOwnerTypeId,
# #     [12] :IsActive,
# #     [13] :MetaContent,
# #     [14] :RadialMembershipId,
# #     [15] :IsSyncNeeded


# #      DB[:Provider].join_table(:inner, :Broker, Provider_ID: :Provider_ID).join_table(:inner, :Client, Client_ID: :Client_ID).join_table(:inn
# #  er, :ClientType, ClientType_ID: :ClientType_ID)


# #  RPGDB = Sequel.connect(AppConfig.get["RPG"])
# # ds = RPGDB[:AbpUsers].join_table(:inner, :OrganizationUsers, UserId: :Id)
# # data = ds.pluck(:UserId, :Id, :UserName, :Name, :Surname, :BusinessAbb, :BusinessName, :IsSyncNeeded)
# # header = [:UserId, :OrgUserId, :UserName, :Name, :Surname, :BusinessAbb, :BusinessName, :IsSyncNeeded]
# #  CSV.open("reports/abp.csv", "wb") { |csv|  csv << header; data.each { |row| csv<<row } } 


# options = {}
# options[:filename] = "reports/final_mapping.csv"
# options[:data] = ds
# options[:header]= [:brokerId, :orgUserId, :businessAbbr,  :stage_of_life, :book_name, :funding_source, :templateId, :aggre
# gator, :aggregatorId]

# # DB[:Provider].join_table(:inner, :Broker, Provider_ID: :Provider_ID).join_table(:inner, :Client, Client_ID: :Client_ID).join_table(:inn
#  er, :ClientType, ClientType_ID: :ClientType_ID)

# ##Total number of records
# #tab.inject(0) { |count, tab| count += DB[tab].select(:File_Name).distinct.count }

# ## Number of distinct records in each tables
# #tab.inject(0) { |count, tab| count += DB[tab].select(:File_Name).distinct.count }


# ## All distinct filenames
# #files = tab.inject([]) do |count, tab| 
# count << DB[tab].select(:File_Name).distinct.to_a 
# end 



### Find out User Org Id for each broker in new system
ImportKeyMap.brokermap
RPGDB = Sequel.connect(AppConfig.get["RPG"])
ds = RPGDB[:AbpUsers].join_table(:inner, :OrganizationUsers, UserId: :Id)
ds.select(:Id, :BusinessAbb).to_a
user_org_id_hash = Hash.new
ap ds.to_a.each { |a| user_org_id_hash[a[:BusinessAbb].downcase.to_sym] = a[:Id] unless a[:BusinessAbb].nil? }


rs = RPGDB[:Aggregators].join_table(:inner, :Templates, AggregatorId: :Id).to_a
aggregator_template_id_hash = Hash.new
rs.to_a.each { |a| aggregator_template_id_hash[a[:ShortName].downcase.to_sym] = a[:Id] unless a[:ShortName].nil? }
RPGDB.disconnect
BrokerMap = ImportKeyMap.brokermap.each do |bm| 
    bm[1][:user_org_id] = user_org_id_hash[bm[1][:business_abbrevation].downcase.to_sym]
    bm[1][:template_id] = aggregator_template_id_hash[bm[1][:aggregator].downcase.to_sym]
end

ap BrokerMap
