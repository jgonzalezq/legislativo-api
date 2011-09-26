# Spanish for 'bill'
class Proyecto
  include Mongoid::Document
  include Mongoid::Timestamps

  index :identifier
  index :coauthor_ids
  index :coauthor_count
  index :author_id
  index "author.region"
end


# record information about every API request
class Hit
  include Mongoid::Document
  
  index :created_at
  index :method
  index :sections
  index :user_agent
end