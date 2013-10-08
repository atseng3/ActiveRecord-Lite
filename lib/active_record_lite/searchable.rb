require_relative './db_connection'

module Searchable
  def where(params)
    keys = params.keys.map { |attr| "#{attr} = ?"}.join(" AND ")
    query = <<-SQL
    SELECT * 
    FROM #{self.table_name}
    WHERE #{keys}
    SQL
    found_object = DBConnection.execute(query, *params.values)
    self.parse_all(found_object)
    # found_object.map { |f_obj| self.new(f_obj) }
  end
end