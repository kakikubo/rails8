config = {
    host: "http://elasticsearch:9200/"
}

if File.exists?("config/elasticsearch.yml")
  config.merge!(YAML.load_file("config/elasticsearch.yml", aliases: true)[Rails.env].deep_symbolize_keys)
end

#Elasticsearch::Model.client = Elasticsearch::Client.new(config)
