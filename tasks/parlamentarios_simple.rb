class ParlamentariosSimple
  
  def self.run(options = {})
    mysql = options[:mysql]
    
    count = 0
    
    # load in all fields on all parliamentarians from the main table
    rows = mysql.query "select * from Parlamentario"
    
    rows.each do |row|
      # if it already exists, find it, otherwise, create it
      parlamentario = Parlamentario.find_or_initialize_by(:identifier => row['id_parlamentario'])
      
      parlamentario.attributes = {
        :nombre => row["nombre"],
        :apellidos => row["apellidos"],
        :senador_diputado => row["senador_diputado"]
      }
      
      if parlamentario.save
        count += 0
        puts "[#{parlamentario['identifier']}] Updated record"
      else
        puts "Failed to save a parlamentario, errors: #{parlamentario.errors.full_messages.join ', '}"
      end
    end
    
  end
  
end