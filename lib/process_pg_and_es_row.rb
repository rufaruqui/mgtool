 
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
         
        @comm_type   = ImportKeyMap.perform(:HardCodedCommissionType)
        @lender_type = ImportKeyMap.perform(:HardCodedLender)
        @month_name  = ImportKeyMap.perform(:MonthName)
        @cols = ImportKeyMap.perform(@table_name)
        @brokermap = BrokerMap[[@data.first[:Broker_ID].to_i, @cols[:aggregator].downcase.to_sym]]  || ImportKeyMap.dummy_data
      

        file_name = (@data.first[:File_Name]).split("/").last.gsub("_","-")

        rh = Hash.new
        rh[:Name]= file_name
        rh[:OrganizationUserId]=  @brokermap[:user_org_id].to_i
        rh[:TemplateId] = @brokermap[:template_id].to_i
        rh[:FileKey] = set_filekey(file_name)
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
          contents[:aggregatorName] = @brokermap[:aggregator_name]
          contents[:businessName] = @brokermap[:business_name]
          contents[:commissionMonth], contents[:commissionDate]= extract_mon_year file_name
          contents[:silo]= @brokermap[:funding_source]
          contents[:book] = @brokermap[:book_name]
          contents[:stageOfLife] = @brokermap[:stage_of_life]
        rh[:MessageContent] = contents
        DbService.insert_row rh, @data.first[:Broker_ID].to_i
     end
     
     def self.preapare_nested_contents data
          nested_contents= []

              if @table_name == :Import_RZ1 
                data.each { |d| nested_contents<< prepare_data_for_contents_import_red_zed(d) }
              elsif   @table_name == :Import_Connective2
                data.each { |d| nested_contents<< prepare_data_for_contents_connective(d) }
              else 
                 data.each { |d|  nested_contents << prepare_data_for_contents(d) }
              end

          nested_contents  
     end


      def self.check_commission_type k,v
         if k == :HardCodded
              @comm_type[@table_name] 
         elsif k == :Commission_Type_ID
             return  @Commission_Type_ID[v]
          elsif !v.nil?
              return CommType[v.downcase.to_sym] 
          else
               return "TC"
         end
     end


     # def self.check_commission_type k,v
     #     if k == :HardCodded
     #          @comm_type[@table_name] 
     #     elsif k == :Commission_Type_ID
     #         return  @Commission_Type_ID[v]
     #      elsif (!v.nil? and v.downcase.to_sym == :"referrer upfront")
     #           return "RU"
     #      elsif (!v.nil? and v.downcase.to_sym == :"referrer trail")
     #           return "RT"     
     #      elsif (!v.nil? and v.downcase.include? ("trails" or "tc"))
     #          return "TC"
     #     elsif (!v.nil? and v.downcase.match? ("up" or "uc" or "ufc"))
     #           return "UC"
     #      elsif (!v.nil? and v.downcase.include? ("arr" or "arrears"))
     #           return "AR"
     #      elsif (!v.nil? and v.downcase.to_sym == :dis)
     #           return "DI"
     #      elsif (!v.nil? and v.downcase.to_sym == :clowback)
     #           return "CB"
     #      else
     #          return "TC"
     #     end
     # end

     def self.extract_mon_year file_name 
           return_date =  [Time.now.strftime("%B %Y"), Time.now.to_i] 
           m = file_name.split("-").last.match /(?<mon>\w{3,12})(.?)(?<year>\d{2,4})/
           
           m = file_name.match /(?<mon>\w{3,12})(.?)(?<year>\d{2,4})/ if m.nil?
           
         begin 
           #d =   DateTime.parse "01-"+m[:mon] + "-" + m[:year].to_s
           d =   DateTime.parse [(m[:year].length == 2 )? "20"+m[:year] : m[:year], m[:mon].to_s,"01"].join("-")
           return_date = [d.strftime("%B %Y"), d]
         rescue
            m = file_name.split("-").last.match /(?<year>\d{2,4})(?<mon>\d{2})(?<day>\d{2})/
            d =   DateTime.parse [(m[:year].length == 2 )? "20"+m[:year] : m[:year], m[:mon].to_s,"01"].join("-")
            puts "Invalid date in #{file_name}. Inserting current time for Commission Month".red
            MyLogger.error "Invalid date in #{file_name}. Inserting current time for Commission Month: #{d.strftime("%B %Y")}" 
            return_date = [d.strftime("%B %Y"), d]
            return_date 
         end unless m.nil?
         return_date        
     end

     def self.prepare_data_for_contents d 
          ch = Hash.new
          ch[:customerName] =    d[@cols[:contents][:customerName]]
          ch[:loanAccountNo] =   d[@cols[:contents][:loanAccountNo]]
          ch[:totalCommission] = d[@cols[:contents][:totalCommission]].to_f
          ch[:commissionType] =  check_commission_type @cols[:contents][:commissionType], d[@cols[:contents][:commissionType]] #(ch[:commissionType] == :Commission_Type_ID) ? @Commission_Type_ID[d[cols[:contents][:commissionType]].to_i] : (!d[cols[:contents][:commissionType]].nil? and d[cols[:contents][:commissionType]].downcase.include? "trail" or "tc") ? "TC" : "UC"  ##ToDO: -- Bring CommissionTypeWithID]   
          ch[:loanBalance] = d[@cols[:contents][:loanBalance]].nil? ? 0.0 : d[@cols[:contents][:loanBalance]].to_f
          ch[:loanAmount] =  d[@cols[:contents][:loanAmount]].nil? ?  0.0 : d[@cols[:contents][:loanAmount]].to_f 
          ch[:settlementDate] = d[@cols[:contents][:settlementDate]]
          ch[:lender] = @cols[:contents][:lender] == :HardCoded ? @lender_type[@table_name] : lender_from_manufacturer_ref(d[@cols[:contents][:lender]])
          return ch
     end


       def self.prepare_data_for_contents_connective d 
          ch = Hash.new
          ch[:customerName] =    d[@cols[:contents][:customerName]]
          ch[:loanAccountNo] =   d[@cols[:contents][:loanAccountNo]]
          ch[:totalCommission] = d[@cols[:contents][:totalCommission]].to_f
          ch[:commissionType] =  check_commission_type @cols[:contents][:commissionType], d[@cols[:contents][:commissionType]] #(ch[:commissionType] == :Commission_Type_ID) ? @Commission_Type_ID[d[cols[:contents][:commissionType]].to_i] : (!d[cols[:contents][:commissionType]].nil? and d[cols[:contents][:commissionType]].downcase.include? "trail" or "tc") ? "TC" : "UC"  ##ToDO: -- Bring CommissionTypeWithID]   
          ch[:loanBalance] = d[@cols[:contents][:loanBalance]].nil? ? 0.0 : d[@cols[:contents][:loanBalance]].to_f
          ch[:loanAmount] =  d[@cols[:contents][:loanAmount]].nil? ?  0.0 : d[@cols[:contents][:loanAmount]].to_f
          ch[:loanBalance] =  ch[:loanAmount] if ch[:commissionType] == "UC"
          ch[:settlementDate] = d[@cols[:contents][:settlementDate]]
          ch[:lender] = @cols[:contents][:lender] == :HardCoded ? @lender_type[@table_name] : lender_from_manufacturer_ref(d[@cols[:contents][:lender]])
          return ch
     end

     def self.lender_from_manufacturer_ref lender
          len = ManufacturerHash[lender.strip.downcase.to_sym] unless lender.nil?
          len = len.match /(?<lenabb>\(?\w{2,50}?\))/ unless len.nil?
          return (len.nil?)? lender : len[:lenabb][1..-2]
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
               ch[:totalCommission] = 0.0
               ch[:commissionType] ="TC"
          end

          ch[:loanBalance] = d[@cols[:contents][:loanBalance]].nil? ? 0.0 : d[@cols[:contents][:loanBalance]].to_f
          ch[:loanAmount] =  d[@cols[:contents][:loanAmount]].nil? ? 0.0  : d[@cols[:contents][:loanAmount]].to_f
          ch[:settlementDate] = d[@cols[:contents][:settlementDate]]
          ch[:lender] = @cols[:contents][:lender] == :HardCoded ? @lender_type[@table_name] : lender_from_manufacturer_ref(d[@cols[:contents][:lender]])
          return ch
     end

     def self.set_filekey file_name
      #SecureRandom.urlsafe_base64(32)+'='
      Base64.urlsafe_encode64(file_name)
   end
   

end


 