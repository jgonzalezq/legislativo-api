# adds linked objects to Votacion documents

class LinkVotacions
  
  def self.run(options = {})
    
    Votacion.all.each do |votacion|
      
      if votacion['id_proyecto_ley']
        if proyecto = Proyecto.where(:id_proyecto_ley => votacion['id_proyecto_ley']).first
          votacion['proyecto'] = TaskUtils.allowed_fields(proyecto, Proyecto.basic_fields)
        else
          puts "Failed to look up proyecto by id: #{votacion['id_proyecto_ley']}"
        end
      end
      
      if votacion.save
        puts "[#{votacion['id_votacion']}] Linked information to votacion"
      else
        puts "Failed to save a votacion, errors: #{votacion.errors.full_messages.join ', '}"
      end
    end
    
  end
  
end