require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable
  
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
    SELECT * 
    FROM #{@table_name}
    SQL
    rows.each { |row| self.new(row) }
  end

  def self.find(id)
    found_object = DBConnection.execute(<<-SQL).first
    SELECT *
    FROM #{@table_name}
    WHERE id = id
    SQL
    return nil if found_object.nil?
    self.new(found_object)
  end

  def create
    attr_names = self.class.attributes.join(", ")
    attr_names = attr_names[4..-1]
    q_marks = (['?']*(self.class.attributes.count-1)).join(", ")
    attr_values = attribute_values
    DBConnection.execute(<<-SQL, *attr_values)
    INSERT INTO #{self.class.table_name} (#{attr_names})
    VALUES (#{q_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.attributes.map { |attr| "#{attr}= ?"}.join(", ")
    set_line = set_line[7..-1]
    attr_values = attribute_values
    DBConnection.execute(<<-SQL, *attr_values)
    UPDATE #{self.class.table_name}
    SET #{set_line}
    WHERE id = #{self.id}
    SQL
  end

  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  def attribute_values
    attr_values = []
    self.class.attributes.each { |attr| attr_values << self.send(attr) }
    attr_values = attr_values[1..-1]
  end
end