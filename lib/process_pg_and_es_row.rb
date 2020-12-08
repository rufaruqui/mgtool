 
class ProcessPgAndEsRow
    
    def self.perform(options={}, table_name)
       return if options.empty?
        @data = options
        @table_name = table_name.to_sym
        @Commission_Type_ID = {}

        @Commission_Type_ID[1] = "UC"
        @Commission_Type_ID[2] = "TC"
        @Commission_Type_ID[3] = "DI"  #DIS --> DI
        @Commission_Type_ID[4] = "AR"   #AR-->"ARREAR"  
        @Commission_Type_ID[5] = "OTHER"
        @Commission_Type_ID[6] = "DIS_APP"  #DISRPG
        @Commission_Type_ID[6] = "InsLife"
         
        @comm_type = ImportKeyMap.perform(:HardCodedCommissionType)
        @lender_type = ImportKeyMap.perform(:HardCodedLender)
        @month_name  = ImportKeyMap.perform(:MonthName)

        @cols = ImportKeyMap.perform(@table_name)

        @brokermap = BrokerMap[@data.first[:Broker_ID].to_i] || ImportKeyMap.dummy_data
      
        file_name = (@data.first[:File_Name]).split("/").last

        rh = Hash.new
        rh[:Name]= file_name
        rh[:OrganizationUserId]=  @brokermap[:user_org_id].to_i
        rh[:TemplateId] = @brokermap[:template_id].to_i
        rh[:FileKey] = set_filekey
        rh[:FileType] = (file_name.split(".").last.downcase.to_sym == :xls or :xlsx) ? 2 : 1 

          contents = Hash.new
          contents[:name] = rh[:Name]
          contents[:templateId] = rh[:TemplateId]
          contents[:fileKey] = rh[:FileKey]
          contents[:contents] = preapare_nested_contents @data
          contents[:broker] = @brokermap[:business_abbrevation]                         #@data.first[:Broker_ID].to_i
          contents[:importDate] = @data.first[:Report_Date]                             #unless @data.first[:Report_Date].nil?
          contents[:brokerOrgUserId] = @brokermap[:user_org_id].to_i
          contents[:aggregator] = @brokermap[:aggregator]
          contents[:commissionMonth]= extract_mon_year file_name
          contents[:silo]= @brokermap[:funding_source]
          contents[:book] = @brokermap[:book_name]
          contents[:stageOfLife] = @brokermap[:stage_of_life]
        rh[:MessageContent] = contents
        DbService.insert_row rh 
     end
     
     def self.preapare_nested_contents data
          nested_contents= []
          data.each do |d| 
              if @table_name == :Import_RZ1 
                 nested_contents<< prepare_data_for_contents_import_red_zed(d) 
              else 
                 nested_contents << prepare_data_for_contents(d)
              end
          end
          nested_contents  
     end

     def self.check_commission_type k,v
         if k == :HardCodded
              @comm_type[@table_name] 
         elsif k == :Commission_Type_ID
             return  @Commission_Type_ID[v]
          elsif (!v.nil? and v.downcase.to_sym == :"referrer upfront")
               return "RU"
          elsif (!v.nil? and v.downcase.to_sym == :"referrer trail")
               return "RT"     
          elsif (!v.nil? and v.downcase.include? ("trails" or "tc"))
              return "TC"
         elsif (!v.nil? and v.downcase.include? ("up" or "uc" or "ufc"))
               return "UC"
          elsif (!v.nil? and v.downcase.to_sym == :dis)
               return "DI"
          elsif (!v.nil? and v.downcase.to_sym == :clowback)
               return "CB"
          else
              return "TC"
         end
     end

     def self.extract_mon_year file_name 
           m = file_name.match /(?<mon>\w{3})(?<year>\d+)/
           @month_name[m[:mon].downcase.to_sym].to_s + " " + m[:year].to_s unless m.nil?
     end

     def self.prepare_data_for_contents d 
          ch = Hash.new
          ch[:customerName] =    d[@cols[:contents][:customerName]]
          ch[:loanAccountNo] =   d[@cols[:contents][:loanAccountNo]]
          ch[:totalCommission] = d[@cols[:contents][:totalCommission]].to_f
          ch[:commissionType] =  check_commission_type @cols[:contents][:commissionType], d[@cols[:contents][:commissionType]] #(ch[:commissionType] == :Commission_Type_ID) ? @Commission_Type_ID[d[cols[:contents][:commissionType]].to_i] : (!d[cols[:contents][:commissionType]].nil? and d[cols[:contents][:commissionType]].downcase.include? "trail" or "tc") ? "TC" : "UC"  ##ToDO: -- Bring CommissionTypeWithID]   
          ch[:loanBalance] = d[@cols[:contents][:loanBalance]].nil? ? 0: d[@cols[:contents][:loanBalance]].to_f
          ch[:loanAmount] =  d[@cols[:contents][:loanAmount]].nil? ? 0 : d[@cols[:contents][:loanAmount]].to_f
          ch[:settlementDate] = d[@cols[:contents][:settlementDate]]
          ch[:lender] = @cols[:contents][:lender] == :HardCoded ? @lender_type[@table_name] : d[@cols[:contents][:lender]]
          return ch
     end


     def self.prepare_data_for_contents_import_red_zed d 
          ch = Hash.new
          ch[:customerName] =    d[@cols[:contents][:customerName]]
          ch[:loanAccountNo] =   d[@cols[:contents][:loanAccountNo]]

          if(d[:Trailing_Amount_Payable] > 0)
               ch[:totalCommission] = d[:Trailing_Amount_Payable]
               ch[:commissionType] = "TC"
          elsif (d[:Up_Front_Amount_Payable] > 0)
               ch[:totalCommission] = d[:Up_Front_Amount_Payable]
               ch[:commissionType] = "UC"
          else
               ch[:totalCommission] = 0
               ch[:commissionType] ="TC"
          end

          ch[:loanBalance] = d[@cols[:contents][:loanBalance]].nil? ? 0: d[@cols[:contents][:loanBalance]].to_f
          ch[:loanAmount] =  d[@cols[:contents][:loanAmount]].nil? ? 0 : d[@cols[:contents][:loanAmount]].to_f
          ch[:settlementDate] = d[@cols[:contents][:settlementDate]]
          ch[:lender] = @cols[:contents][:lender] == :HardCoded ? @lender_type[@table_name] : d[@cols[:contents][:lender]]
          return ch
     end

     def self.set_filekey
      SecureRandom.urlsafe_base64(32)+'='
   end

end