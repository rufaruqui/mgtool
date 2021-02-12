require 'active_support/core_ext/hash/indifferent_access'

APP_ENV = "development"

## Uncomment it for production
#APP_ENV = "production"

## Uncomment it for staging
#APP_ENV = "staging"


class AppConfig  
       @@config= YAML.load_file('config/app_config.yml').with_indifferent_access
    def self.get(options={})
       @@config[APP_ENV]
    end
end