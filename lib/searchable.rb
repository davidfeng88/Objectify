require_relative 'db_connection'

module Searchable
  def where(params)
    where_line = params.keys.map {|key| "#{key} = ?"}.join(" AND ")
    vals = params.values

    results = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    parse_all(results)
  end
end
