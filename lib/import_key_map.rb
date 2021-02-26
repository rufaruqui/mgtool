require 'csv'
require 'active_support/core_ext/hash/indifferent_access'
 
class MyCsvReader

    def self.read filename
        if File.exist? filename
            pp "Reading files: " + filename
            return  CSV.read(filename,  :headers => true, :header_converters => :symbol)
        else
            pp "File missing: " + filename
            return nil
        end
    end

    def self.csv_to_composite_hash filename
        data = read filename

        h = Hash.new

        data.each do |d|
           h[[d[:broker_id].to_i, d[:aggregator].downcase.to_sym]] = d
        end
        return h
    end

    def self.write options
        CSV.open(options[:filename], "wb") do |csv|  
            csv << options[:header]
            options[:data].each  do |tab| 
                csv<<tab[1] 
            end
        end   
    end 
end

class ImportKeyMap
       @@keymap =  YAML.load_file('config/mappings.yml').with_indifferent_access
     
    def self.perform table_name
          @@keymap[table_name.to_sym] 
    end

    def self.create_csv filename, options
       filename = File.join('config', filename)
      CSV.open(filename,"w") do |file|
         file << options.first.keys
         options.each { |data| file<<data.values }
       end unless options.empty?
     end 

     def self.dummy_data 
      h = Hash.new

      h[:dump] = "",
      h[:broker_id] = 0,
      h[:provider_name] = "",
      h[:funding_source] = "",
      h[:client_name] = "",
      h[:broker_name] = "",
      h[:email_go_live] = "",
      h[:business_name] = "",
      h[:business_contact_first_name] = "",
      h[:business_contact_last_name] = "",
      h[:business_abbrevation] = "",
      h[:aggregators] = "",
      h[:aggregator] = "",
      h[:stage_of_life] = "",
      h[:book_name] = ""
      return h
   end

end