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
  # pass in command line flags as options to the task
  # for example:
  # "rake task:get_proyectos session=100 debug=true" 
  # becomes:
  # GetLegislators.run({:debug => "true"})
  options = {}
  ARGV[1..-1].each do |arg|
    key, value = arg.split '='
    if key.present? and value.present?
      options[key.downcase.to_sym] = value
    end
  end
  
  start = Time.now
  load "tasks/#{name}.rb"
  name.camelize.constantize.run options
  
  puts "Completed running #{name} in #{Time.now - start}s"
end