class Proyecto
  include Mongoid::Document
  include Mongoid::Timestamps

  index :id_proyecto_ley
end

class Comision
  include Mongoid::Document
  include Mongoid::Timestamps

  index :id_comision
end

class Parlamentario
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :id_parlamentario
end


# record information about every API request
class Hit
  include Mongoid::Document
  
  index :created_at
  index :method
  index :sections
  index :user_agent
end