class Comision
  include Mongoid::Document
  include Mongoid::Timestamps

  index :identifier
end

class Parlamentario
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :identifier
end


# record information about every API request
class Hit
  include Mongoid::Document
  
  index :created_at
  index :method
  index :sections
  index :user_agent
end