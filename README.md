<div align="center">
  A data migrations tool
</div>

## Setup/Installation
 
  ### Install Ruby Version Manager `rvm`
  ```
  sudo apt-get update
  sudo apt-get install -y curl gnupg build-essential libpq-dev
  sudo gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | sudo bash -s stable
  sudo usermod -a -G rvm `whoami`

  ```
   
  ### Install Ruby 

  ```
    rvm install ruby-X.X.X
    rvm --default use ruby-X.X.X
  ```

  ### Install Ruby Bundler
  ```
    gem install bundler --no-rdoc --no-ri
  ```

## Configuration 
  Uncomment folloing line in `classes\app_config.rb`

```
  APP_ENV = "production"
```
  Bundle all of your gems. Go to app folder and run following command

  ```
   bundle
  ```

## Running task

### Importing all tables from MySQL to PG
```
 rake import_all_tables
```
### Insert data into Elastic Search (run this after all insertion)

```
  rake insert_into_es
```
