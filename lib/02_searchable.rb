require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map {|key| "#{key} = ?"}.join(" AND ")
    vals = params.values

    results_as_array_of_hashes = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    # solution:
    # parse_all(results)

    results_as_array_of_objects = []
    results_as_array_of_hashes.each do |hash|
      new_obj = self.new(hash)
      results_as_array_of_objects << new_obj
    end
    results_as_array_of_objects
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
