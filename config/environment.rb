require 'json/ext'
require 'sinatra'
require 'mongoid'
require 'tzinfo'

# disable logging 
set :logging, false


# loads in config.yml as a hash and caches it for future calls
def config
  @config ||= YAML.load_file File.join(File.dirname(__FILE__), "config.yml")
end


# this block runs only once when the server is started
configure do
  
  # configure Mongoid to point to the specified MongoDB server
  config[:mongoid][:logger] = Logger.new config[:log_file] if config[:log_file]
  Mongoid.configure {|c| c.from_hash config[:mongoid]}
  
  # A default time zone for when people search by date (with no time), or a time that omits the time zone
  Time.zone = ActiveSupport::TimeZone.find_tzinfo "America/Santiago"
end


# after initializing Mongoid, load in models, and make a method so others can see them
require 'models'

def models
  [Parlamentario, Comision, Proyecto, Votacion, Debate]
end

# reload changes made in development to key files without having to restart the server
configure(:development) do |config|
  require 'sinatra/reloader'
  config.also_reload "api.rb"
  config.also_reload "models.rb"
end

# special fields used by the system, cannot be used on a model (on the top level)
def magic_fields
  [
    # reserve this for use in JSONP support 
    :callback, 
    
    # jQuery uses this to bust caches, allow this and don't try to filter on it as a field
    :_, 
    
    # Sinatra uses this as a keyword to do route parsing
    :captures,
    
    # allow for specifying of partial fields
    :fields,
    
    # trigger an explanation of the query
    :explain,
    
    # sorting parameters
    :sort, :order,
    
    # pagination parameters
    :page, :per_page
  ]
end
