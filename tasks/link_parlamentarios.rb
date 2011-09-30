class LinkParlamentarios
  
  def self.run(options = {})
    
    # link parlamentarios to their comisions
    
    # cache all the comisions
    comisions_cache = {}
    Comision.all.each do |comision|
      comisions_cache[comision['id_comision']] = TaskUtils.allowed_fields(comision, Comision.basic_fields)
    end
    
    Parlamentario.all.each do |parlamentario|
      comision_ids = []
      comisions = []
      
      query = "select * from ParlamentarioEnComision where id_parlamentario = #{parlamentario['id_parlamentario']}"
      
      options[:mysql].query(query).each do |link|
        if comision = comisions_cache[link['id_comision']]
          comision_ids << link['id_comision']
          comisions << comision
        end
      end
      
      parlamentario['comision_ids'] = comision_ids
      parlamentario['comisions'] = comisions
      
      if parlamentario.save
        puts "[#{parlamentario['id_parlamentario']}] Updated committee links for parlamentario"
      else
        puts "Failed at updating parlamentario, errors: #{parlamentario.errors.full_messages.join ', '}"
      end
    end
    
  end
  
end