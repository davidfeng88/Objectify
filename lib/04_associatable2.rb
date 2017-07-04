require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    # solution: even line 8 is in the define_method block
    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      top_class = source_options.class_name
      top_id = source_options.foreign_key
      mid_class = through_options.class_name
      mid_id = through_options.foreign_key
      results = DBConnection.execute(<<-SQL, self.id)
        SELECT
          #{top_class.constantize.table_name}.*
        FROM
          #{top_class.constantize.table_name}
        JOIN
          #{mid_class.constantize.table_name}
        ON
          #{top_class.constantize.table_name}.id = #{mid_class.constantize.table_name}.#{top_id}
        JOIN
          #{self.class.table_name}
        ON
          #{mid_class.constantize.table_name}.id = #{self.class.table_name}.#{mid_id}
        WHERE
          #{self.class.table_name}.id = ?
      SQL

      top_class.constantize.new(results[0])


      # this works, but probably not ideal.. two queries
      # through_object = self.send(through_name)
      # result = through_object.send(source_name)

      # solution: do not have to join 3 tables. 2 tables are enough
      #      through_table = through_options.table_name
      #      through_pk = through_options.primary_key
      #      through_fk = through_options.foreign_key
      #
      #      source_table = source_options.table_name
      #      source_pk = source_options.primary_key
      #      source_fk = source_options.foreign_key
      #
      #      key_val = self.send(through_fk)
      #      results = DBConnection.execute(<<-SQL, key_val)
      #        SELECT
      #          #{source_table}.*
      #        FROM
      #          #{through_table}
      #        JOIN
      #          #{source_table}
      #        ON
      #          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
      #        WHERE
      #          #{through_table}.#{through_pk} = ?
      #      SQL
      #
      #      source_options.model_class.parse_all(results).first
    end
  end
end
