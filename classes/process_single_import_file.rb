class ProcessSingleImportFile
    def self.perform(options={}) 
           @DB = DbService.connect
           one_pg_row = @DB[options[:table_name]].where(:File_Name=>options[:filename])#.limit(100) #, :Commission_Type=>"Upfronts")
           data = one_pg_row.to_a
           
           puts "Processing file : #{options[:filename]} from #{options[:table_name]}".green
           ProcessPgAndEsRow.perform options[:data]=data, options[:table_name] unless  (data.empty?) #or ImportMsFile.find_by(Name:options[:filename].split("/").last )
           true
    end
end