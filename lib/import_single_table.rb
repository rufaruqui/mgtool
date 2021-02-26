class ImportSingleTable  

    def self.perform table 
        if ImportKeyMap.perform(table.to_sym).nil?
            puts "No mapping for table: #{table}".red 
            MyLogger.error "No mapping for table: #{table}"
            return 
        end
        
        uploaded_files = MSDB[table.to_sym].select(:File_Name).distinct
        puts "#{uploaded_files.count} unique files in #{table.to_sym}".red
        MyLogger.info "#{uploaded_files.count} unique files in #{table.to_sym}"

        data = uploaded_files.to_a
        options = Hash.new
        data.each do |filename|
            options[:filename] = filename[:File_Name]
            options[:table_name]=table.to_sym
            ProcessSingleImportFile.perform(options) unless already_uploaded? filename[:File_Name]
            true
        end unless data.empty?  
    end
    def self.already_uploaded? name 
        check = PGDB[:ImportFiles].where(Name:name.split("/").last.gsub("_","-")).count == 1
        #MyLogger.warn "Already processed file : #{name}" if check
        puts "Already processed file : #{name}".yellow if check
        check
    end

    def self.import_all
      start = Time.now
      import_tables = MSDB.tables.filter.each { |t| t.to_s.include? "Import_"  }
      import_tables.each do |table|
            puts "Importing rows form #{table.to_s}".red
            MyLogger.info "Importing rows form #{table.to_s}"
            ImportSingleTable.perform table
        end
        
        finish = Time.now

        diff = ((finish - start)/60).round(2)
        puts "Total time to migrate all data: #{diff} minutes".red
        MyLogger.info "Total time to migrate all data: #{diff} minutes"
    end
end