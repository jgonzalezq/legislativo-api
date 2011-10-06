class GetDebates
  def self.run(options = {})
    count = 0
    
    result = options[:mysql].query("Select * from Debate")
    
    result.each do |row|
      debate = Debate.find_or_initialize_by :id_debate => row["id_debate"]
      
      row = TaskUtils.clean_row row
      if row['tags']
        tags = row['tags'].split(/\s*,\s*/)
        row['tags'] = tags
      end
      debate.attributes = row
      
      if debate.save
        puts "[#{debate["id_debate"]}] Saved Debate"
        count += 1
      else
        puts "Failed to save a debate, errors: #{comision.errors.full_messages.join ', '}"
      end

    end
    puts "Saved #{count} debates"
  end
end
      
      
    


    
