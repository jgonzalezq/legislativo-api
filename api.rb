#!/usr/bin/env ruby

require 'config/environment'

# for example: [Parlamentario, Proyecto] => "parlamentarios|proyectos"
endpoints = models.map do |model| 
  model.to_s.underscore.pluralize
end.join "|"

pattern = /^\/(#{endpoints})/

get pattern do
  # for example: "proyectos" => Proyecto
  model = params[:captures][0].singularize.camelize.constantize
  
  # which fields to request on each document
  fields = fields_for(params)
  
  # fields to filter
  conditions = conditions_for(model, params)
  
 
  order = order_for(model, params)
  
  pagination = pagination_for(params)
  
  if params[:explain] == 'true'
    results = explain_for(model, conditions, fields, order, pagination)
  else
    results = results_for(model, conditions, fields, order, pagination)
  end
  
  response['Content-Type'] = 'application/json'
  json = results.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# log all hits in the database

after pattern do
  Hit.create!(
    :method => params[:captures][0],
    :query_hash => remove_dots(request.env['rack.request.query_hash']).to_hash,
    :user_agent => request.env['HTTP_USER_AGENT'],
    :created_at => Time.now.utc
  )
end


helpers do
  
  def fields_for(params)
    if params[:fields].present?
      params[:fields].split(',').uniq
    end
  end
  
  def conditions_for(model, params)
    conditions = {}
    
    params.each do |key, value|
      if !magic_fields.include? key.to_sym
        conditions[key] = value_for value, model.fields[key]
      end
    end
    
    conditions
  end
  
  def order_for(model, params)
    key = nil
    if params[:sort].present?
      key = params[:sort].to_sym
    else
      key = :_id
    end
    
    order = nil
    if params[:order].present? and [:desc, :asc].include?(params[:order].downcase.to_sym)
      order = params[:order].downcase.to_sym
    else
      order = :desc
    end
    
    [[key, order]]
  end

  def attributes_for(document, fields)
    attributes = document.attributes
    ['_id', 'created_at', 'updated_at'].each {|key| attributes.delete(key) unless (fields || []).include?(key.to_s)}
    attributes
  end
  
  def results_for(model, conditions, fields, order, pagination)
    criteria = criteria_for model, conditions, fields, order, pagination
    
    count = criteria.count
    documents = criteria.to_a
    
    key = model.to_s.underscore.pluralize
    
    {
      key => documents.map {|document| attributes_for document, fields},
      :count => count,
      :page => {
        :count => documents.size,
        :per_page => pagination[:per_page],
        :page => pagination[:page]
      }
    }
  end
  
  def explain_for(model, conditions, fields, order, pagination)
    criteria = criteria_for model, conditions, fields, order, pagination
    
    cursor = criteria.execute
    count = cursor.count
    
    {
      :conditions => conditions,
      :fields => fields,
      :order => order,
      :explain => cursor.explain,
      :count => count,
      :page => {
        :per_page => pagination[:per_page],
        :page => pagination[:page]
      }
    }
  end
  
  def criteria_for(model, conditions, fields, order, pagination)
    skip = pagination[:per_page] * (pagination[:page]-1)
    limit = pagination[:per_page]
    
    model.where(conditions).only(fields).order_by(order).skip(skip).limit(limit)
  end
  
  def pagination_for(params)
    default_per_page = 20
    max_per_page = 500
    max_page = 200000000 # let's keep it realistic
    
    # rein in per_page to somewhere between 1 and the max
    per_page = (params[:per_page] || default_per_page).to_i
    per_page = default_per_page if per_page <= 0
    per_page = max_per_page if per_page > max_per_page
    
    # valid page number, please
    page = (params[:page] || 1).to_i
    page = 1 if page <= 0 or page > max_page
    
    {:per_page => per_page, :page => page}
  end
  
  def regex_for(value, i = true)
    regex_value = value.dup
    %w{+ ? . * ^ $ ( ) [ ] { } | \ }.each {|char| regex_value.gsub! char, "\\#{char}"}
    i ? /#{regex_value}/i : /#{regex_value}/
  end
  
  def value_for(value, field)
    
    if field  # the field type is overridden in model
      if field.type == Boolean
        (value == "true") if ["true", "false"].include? value
      elsif field.type == Integer
        value.to_i
      elsif [Date, Time, DateTime].include?(field.type)
        Time.parse(value) rescue nil
      else
        value
      end
      
    
    else  # try to autodetect type
      if ["true", "false"].include? value # boolean
        value == "true"
      elsif value =~ /^\d+$/
        value.to_i
      elsif (value =~ /^\d\d\d\d-\d\d-\d\d$/) or (value =~ /^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d/)
        Time.parse(value) rescue nil
      else
        value
      end
    end
  end
  
end


# break out dot-separated fields into sub-documents.
# for example:
# {"title.given_at" => "foo"}
# becomes"
# {"title" => {"given_at" => "foo"}}

# this is done because MongoDB cannot store field names with dots in them.

def remove_dots(hash)
  new_hash = {}
  hash.each do |key, value|
    bits = key.split '.'
    break_out new_hash, bits, value
  end
  new_hash
end

def break_out(hash, keys, final_value)
  if keys.size > 1
    first = keys.first
    rest = keys[1..-1]
    
    # default to on
    hash[first] ||= {}
    
    break_out hash[first], rest, final_value
  else
    hash[keys.first] = final_value
  end
end