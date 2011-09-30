class GetProyectos
  
  def self.run(options = {})
    
    count = 0
    
    options[:mysql].query("select * from ProyectoLey").each do |row|
      proyecto = Proyecto.find_or_initialize_by(:id_proyecto_ley => row["id_proyecto_ley"])
      
      proyecto.attributes = TaskUtils.clean_row row
      
      if proyecto.save
        count += 1
        puts "[#{proyecto['identifier']}] Updated proyecto"
      else
        puts "Failed to save a comision, errors: #{proyecto.errors.full_messages.join ', '}"
      end
      
    end
    
    puts "Saved #{count} proyecto"
    
  end
  
end