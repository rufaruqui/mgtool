require "elasticsearch"

class SearchClient
       @@client = Elasticsearch::Client.new AppConfig.get["ES"]
    def self.client(options={})
        @@client
    end
   
    def self.put_mapping index_name="impcomsn-"
     @@mappings = JSON.parse(File.read("config/es_mappings.json"), symbolize_names: true).freeze
     @@client.indices.put_mapping(index: index_name, body: @@mappings)
    end

    def self.insert_single_row  data, index_name="impcomsn-"
      puts "Upserting (Insert/Update) #{data[:Name]} into elastic search".blue
      @@client.index(index: index_name, id: data[:FileKey], body: data[:MessageContent])
      true
    end


    # def self.insert_bulk data, index_name="impcomsn-"
    #    data.each do |d|
    #      @@client.index(index: index_name, id: d[:FileKey],  body: d[:MessageContent])
    #    end
    #    true
    # end
    
    def self.insert_bulk body, index_name="impcomsn-"
      id = (PGDB[:ImportFiles].columns.include? :Id) ? :Id : :id
      client.bulk index: index_name,
            type:  '_doc',
            body:  PGDB[:ImportFiles].all.as_json.map { |a| { index: { _id: a.delete(id), data: a } } },
            refresh: true
    end

    
end
