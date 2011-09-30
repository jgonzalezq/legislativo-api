class GetVotacions
  
  def self.run(options = {})
    
    count = 0
    
    options[:mysql].query("select * from Votacion").each do |row|
      votacion = Votacion.find_or_initialize_by(:id_votacion => row["id_votacion"])
      
      votacion.attributes = TaskUtils.clean_row row
      
      if votacion.save
        count += 1
        puts "[#{votacion['id_votacion']}] Updated votacion"
      else
        puts "Failed to save a votacion, errors: #{votacion.errors.full_messages.join ', '}"
      end
      
    end
    
    puts "Saved #{count} votacion"
    
  end
  
end