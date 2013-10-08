require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_accessor :name, :params
  
  def initialize(name, params)
    @name = name
    @params = params
  end
  
  def other_class_name
    @name.to_s.capitalize
  end
  
  def primary_key
    @params[:primary_key] || :id
  end
  
  def foreign_key
    @params[:foreign_key] || (name.to_s + "_id").to_sym
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  attr_accessor :name, :params, :self_class
  
  def initialize(name, params, self_class)
    @name = name
    @params = params
    @self_class = self_class
  end
  
  def other_class_name
    @name.to_s.capitalize.singularize
  end
  
  def primary_key
    @params[:primary_key] || :id
  end
  
  def foreign_key
    @params[:foreign_key].to_s
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    define_method("#{name}") do 
      results = DBConnection.execute(<<-SQL, self.send(aps.foreign_key))
      SELECT *
      FROM #{aps.other_table}
      WHERE id = ?
      SQL
      # Human.where(:id => self.send(params[:foreign_key])).first
      aps.other_class.new(results.first)
    end
    
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)
    define_method("#{name}") do
      query = <<-SQL
      SELECT *
      FROM #{aps.other_table}
      WHERE #{aps.foreign_key} = #{self.id}
      SQL
      results = DBConnection.execute(query)
      results.map { |result| aps.other_class.new(result) }
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
