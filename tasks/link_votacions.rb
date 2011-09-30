# adds linked objects to Votacion documents

class LinkVotacions
  
  def self.run(options = {})
    
    Votacion.all.each do |votacion|
      
      # link the related proyecto
      if votacion['id_proyecto_ley'] and votacion['id_proyecto_ley'] != 0
        if proyecto = Proyecto.where(:id_proyecto_ley => votacion['id_proyecto_ley']).first
          votacion['proyecto'] = TaskUtils.allowed_fields(proyecto, Proyecto.basic_fields)
        else
          puts "Failed to look up proyecto by id: #{votacion['id_proyecto_ley']}"
        end
      end
      
      
      # link all related parlamentario votes
      votantes = []
      votante_ids = []
      
      query = "Select * from VotacionParlamentario where id_votacion = #{votacion['id_votacion']}"
      options[:mysql].query(query).entries.each do |link|
        if parlamentario = Parlamentario.where(:id_parlamentario => link['id_parlamentario']).first
          votante_ids << {
            :id_parlamentario => parlamentario['id_parlamentario'],
            :voto => link['voto']
          }
          votantes << {
            :parlamentario => TaskUtils.allowed_fields(parlamentario, Parlamentario.basic_fields),
            :voto => link['voto']
          }
        else
          puts "Failed to look up parlamentario by id_parlamentario #{link['id_parlamentario']}"
        end
      end
      
      votacion.attributes = {
        :votantes => votantes,
        :votante_ids => votante_ids
      }
      
      
      if votacion.save
        puts "[#{votacion['id_votacion']}] Linked information to votacion"
      else
        puts "Failed to save a votacion, errors: #{votacion.errors.full_messages.join ', '}"
      end
    end
    
  end
  
end