class GetComisions
  
  def self.run(options = {})
    
    count = 0
    
    options[:mysql].query("select * from Comision").each do |row|
      comision = Comision.find_or_initialize_by(:id_comision => row["id_comision"])
      
      comision.attributes = TaskUtils.clean_row row
      
      if comision.save
        count += 1
        puts "[#{comision['id_comision']}] Updated comision"
      else
        puts "Failed to save a comision, errors: #{comision.errors.full_messages.join ', '}"
      end
      
    end
    
    puts "Saved #{count} comisions"
    
  end
  
end
