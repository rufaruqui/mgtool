  class GetBrokerMap 

    def self.get_broker_map 
        ### Find out User Org Id for each broker in new system
        brokermap = MyCsvReader.csv_to_composite_hash "seeds/broker_user_mappings.csv"

   
        Sequel[:column].as(:alias)

        ds = PGDB[:AbpUsers].join_table(:inner, :OrganizationUsers, UserId: :Id)
        user_org_id_hash = Hash.new
        ds.to_a.each { |a| user_org_id_hash[a[:BusinessAbb].downcase.to_sym] = a[:Id] unless a[:BusinessAbb].nil? }
        user_org_id_hash[:lantern] = user_org_id_hash[:lanterncapital] if user_org_id_hash[:lantern].nil?
       
        rs = PGDB[:Aggregators].join_table(:inner, :Templates, AggregatorId: :Id)
        aggregator_template_id_hash = Hash.new
        rs.to_a.each { |a| aggregator_template_id_hash[a[:ShortName].downcase.to_sym] = a[:Id] unless a[:ShortName].nil? }
        
        aggregator_template_id_hash[:cbab] = aggregator_template_id_hash[:cbabus] if aggregator_template_id_hash[:cbab].nil?


        ag = PGDB[:Aggregators]
        ag_names_hash = Hash.new
        ag.to_a.each { |a| ag_names_hash[a[:ShortName].downcase.to_sym] = a[:Name] unless a[:ShortName].nil?}

        brokermap.each do |bm| 
            bm[1][:user_org_id]     = user_org_id_hash[bm[1][:business_abbrevation].downcase.to_sym]
            bm[1][:template_id]     = aggregator_template_id_hash[bm[1][:aggregator].downcase.to_sym]
            bm[1][:aggregator_name] =  ag_names_hash[bm[1][:aggregator].downcase.to_sym]
        end

        #brokermap[16][:template_id]=PGDB[:Templates].order(:Id).last[:Id] if brokermap[16][:template_id].nil?
        return brokermap
    end

    def self.get_manufacturer_reference
        mn  = MSDB[:Manufacturer].select(:Manufacturer_ID, :Manufacturer_Name)
        mnr = MSDB[:ManufacturerReference].select(:Manufacturer_ID, :Manufacturer_Name, :ManufacturerReference_ID)

        mn_hash = Hash.new
        mn.to_a.each { |item| mn_hash[item[:Manufacturer_ID]] = item[:Manufacturer_Name] }

        mnr_hash = Hash.new
        mnr.to_a.each { |item|   mnr_hash[item[:Manufacturer_Name].strip.downcase.to_sym] = mn_hash[item[:Manufacturer_ID]]}
      return mnr_hash
    end

end



# ,d[:aggregator].downcase.to_sym]]