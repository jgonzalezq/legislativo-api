class Bill
  include Mongoid::Document
  include Mongoid::Timestamps
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Relations
  has_many :stage_historys
  has_many :bill_external_references

  # Fields
  field :id, :type => String               # Bulletin Number without dots
  field :title, :type => String
  field :summary, :type => String
  field :tags, :type => Array
  field :matters, :type => Array
  field :stage, :type => String            # Current Stage
  field :creation_date, :type => DateTime
  field :publish_date, :type => DateTime

  # Indexes
  index :id, :unique => true
  index :tags
  index :matters
end

class BillExternalReference
  include Mongoid::Document
  include Mongoid::Timestamps
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Fields
  field :id, :type => Integer
  field :name, :type => String
  field :url, :type => String
  field :date, :type => DateTime

  # Indexes
  index :id, :unique => true

  # Relations
  belongs_to :bill
end

class StageHistory
  include Mongoid::Document
  include Mongoid::Timestamps
  # Field Validation
  validates_presence_of :id
  validates_uniqueness_of :id

  # Fields
  field :id, :type => Integer
  field :stage_name, :type => String
  field :start_date, :type => DateTime
  field :end_date, :type => DateTime

  # Indexes
  index :id, :unique => true

  # Relations
  belongs_to :bill
end

# record information about every API request
class Hit
  include Mongoid::Document

  index :created_at
  index :method
  index :sections
  index :user_agent
end
