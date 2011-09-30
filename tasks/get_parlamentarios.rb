class GetParlamentarios
  
  def self.run(options = {})
    count = 0
    
    # load in all fields on all parliamentarians from the main table
    options[:mysql].query("select * from Parlamentario").each do |row|
      
      parlamentario = Parlamentario.find_or_initialize_by(:id_parlamentario => row['id_parlamentario'])
      
      parlamentario.attributes = TaskUtils.clean_row(row)
      
      if parlamentario.save
        count += 1
        puts "[#{parlamentario['id_parlamentario']}] Updated parlamentario"
      else
        puts "Failed to save a parlamentario, errors: #{parlamentario.errors.full_messages.join ', '}"
      end
    end
    
    puts "Saved #{count} parlamentarios"
    
  end
  
end