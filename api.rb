#!/usr/bin/env ruby

require 'config/environment'

# for example: [Parlamentario, Proyecto] => "parlamentarios|proyectos"
endpoints = models.map do |model|
  model.to_s.underscore.pluralize
end.join "|"

pattern = /^\/(#{endpoints})/

# HTTP GET
get pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize

  # which fields to request on each document
  fields = fields_for(params)

  # fields to filter
  conditions = conditions_for(model, params)

  # how to order the results
  order = order_for(model, params)

  # how to paginate the results
  pagination = pagination_for(params)

  # decide whether this is an explanation response, or a normal response
  if params[:explain] == 'true'
    results = explain_for(model, conditions, fields, order, pagination)
  else
    results = results_for(model, conditions, fields, order, pagination)
  end

  # serialize to JSON and return it
  response['Content-Type'] = 'application/json'
  json = results.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# HTTP POST
post pattern do
    # for example: "foos" => Foo
    model = params[:captures][0].singularize.camelize.constantize

    # fields to filter
    conditions = conditions_for(model, params)

    # the only valid condition to delete a document is by id, the rest are ommited
    conditions.delete_if{|key, value| key != 'id' }

    results = update_for(model, conditions, params)

    # serialize to JSON and return it
    response['Content-Type'] = 'application/json'
    json = results.to_json
    params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# HTTP PUT
put pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize

  if params.include?('id')
    results = insert_for(model, params)
    if results
      status 201
    else
      status 501
      results = {'error' => 'The document couldn\'t be created'}
    end
  else
    status 501
    results = {'error' => 'At least id is required to perform this action'}
  end

  # serialize to JSON and return it
  response['Content-Type'] = 'application/json'
  json = results.to_json
  params[:callback].present? ? "#{params[:callback]}(#{json});" : json
end

# HTTP DELETE
delete pattern do
  # for example: "foos" => Foo
  model = params[:captures][0].singularize.camelize.constantize

  # fields to filter
  conditions = conditions_for(model, params)

  # the only valid condition to delete a document is by id, the rest are ommited
  conditions.delete_if{|key, value| key != 'id' }

  if conditions.size() == 1
    results = delete_for(model, conditions)
    if results
      status 200
    else
      status 501
      results = {'error' => 'The document couldn\'t be deleted'}
    end
  else
    status 501
    results = {'error' => 'id is required to perform this action'}
  end

  # serialize to JSON and return it
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

  # Gets the params
  def fields_for(params)
    if params[:fields].present?
      params[:fields].split(',').uniq
    end
  end

  # Gets the restrictions for data fetching from the params
  def conditions_for(model, params)
    conditions = {}

    params.each do |key, value|
      if !magic_fields.include?(key.to_sym) && model.fields.include?(key)
        conditions[key] = value
      end
    end

    conditions
  end

  # Gets the order from the params
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

  # Deletes documents from the database
  def delete_for(model, conditions)
    criteria = criteria_for(model, conditions)

    documents = criteria.to_a
    # deletes only the first document
    documents[0].delete
  end

  # Inserts documents into the database
  def insert_for(model, params)
    document = model.new

    params.each do |key, value|
      if !magic_fields.include?(key.to_sym) && model.fields.include?(key)
        if model.fields[key].type == Array
          document[key] = value.split('|')
        else
          document[key] = value
        end
      end
    end

    document.save
  end

  # Updates documents in the database
  def update_for(model, conditions, params)
    criteria = criteria_for(model_conditions)
    document = criteria.to_a[0]

    params.each do |key, value|
      if !magic_fields.include?(key.to_sym) && model.fields.include?(key) && key != 'id'
        if model.fields[key].type == Array
          document[key] = value.split('|')
        else
          document[key] = value
        end
      end
    end

    document.save
  end

  # Fetchs database results
  def results_for(model, conditions, fields, order, pagination)
    criteria = criteria_for(model, conditions, fields, order, pagination)

    count = criteria.count
    documents = criteria.to_a

    key = model.to_s.underscore.pluralize

    {
      key => documents.map {|document| attributes_for(document, fields)},
      :count => count,
      :page => {
        :count => documents.size,
        :per_page => pagination[:per_page],
        :page => pagination[:page]
      }
    }
  end

  # Explains the query
  def explain_for(model, conditions, fields, order, pagination)
    criteria = criteria_for(model, conditions, fields, order, pagination)

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

  # Fetchs the documents using conditions and pagination
  def criteria_for(model, conditions, fields = nil, order = nil, pagination = nil)
    if !pagination.nil? && !fields.nil? && !order.nil?
      skip = pagination[:per_page] * (pagination[:page]-1)
      limit = pagination[:per_page]

      model.where(conditions).only(fields).order_by(order).skip(skip).limit(limit)
    else
      model.where(conditions)
    end
  end

  # Does the pagination
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
end


# break out dot-separated fields into sub-documents.
# for example:
# {"title.given_at" => "foo"}
# becomes"
# {"title" => {"given_at" => "foo"}}

# used in storing Hits for analytics.
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