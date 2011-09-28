task :environment do
  require 'rubygems'
  require 'bundler/setup'
  require 'config/environment'
end

desc "Run through each model and create all indexes" 
task :create_indexes => :environment do
  begin
    (models + [Hit]).each do |model| 
      if model.respond_to? :create_indexes
        model.create_indexes 
        puts "Created indexes for #{model}"
      else
        puts "Skipping #{model}, not a Mongoid model"
      end
    end
  rescue Exception => ex
    puts "Error creating indexes: #{ex.message}"
  end
end


# for each Ruby file in tasks, generate a rake task
Dir.glob('tasks/*.rb').each do |file|
  name = File.basename file, File.extname(file)
  
  namespace :tasks do
    task name.to_sym => :environment do
      run_task name
    end
  end
end


def run_task(name)
  # establish mysql connection from details in config.yml
  require 'mysql2'
  mysql = Mysql2::Client.new(
    :hostname => config[:mysql][:hostname], 
    :username => config[:mysql][:username], 
    :password => config[:mysql][:password], 
    :database => config[:mysql][:database]
  )

  # pass in command line flags as options to the task, and always pass the mysql connection
  # for example:
  # "rake task:get_proyectos session=100 debug=true" 
  # becomes:
  # GetLegislators.run({:session => "100", :debug => "true", :mysql => mysql})
  
  options = {:mysql => mysql}
  
  # iterate through each command line argument
  ARGV[1..-1].each do |arg|
    key, value = arg.split '='
    if key.present? and value.present?
      options[key.downcase.to_sym] = value
    end
  end
  
  # log the start of the task
  start = Time.now
  
  # load the task and class by name and call the "run" method on that class
  load "tasks/#{name}.rb"
  name.camelize.constantize.run options
  
  # time to run in seconds
  duration = Time.now - start
  
  puts "Completed running #{name} in #{duration}s"
end