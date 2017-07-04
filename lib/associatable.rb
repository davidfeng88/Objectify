require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    # convert a class name to the class object
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # name is a symbol
    defaults = {
      primary_key: :id,
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # name is a symbol
    defaults = {
      primary_key: :id,
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      foreign_key_value = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => foreign_key_value)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] =
      HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key_value = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => primary_key_value)
    end
  end

  def assoc_options
    @options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
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
