require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'

# for String#tableize
require 'active_support/inflector'

class SQLObject
  extend Searchable
  extend Associatable

  # class methods

  def self.table_name
    # e.g. self is the Dog class. self.to_s and self.name both give "Dog" String
    # tableize = underscore * pluralize
    @table_name ||= self.to_s.tableize
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.columns
    # it returns an array of column names (symbols) in a table
    if @columns.nil?
      # execute2 returns an array, the first element is an array of
      # column names (Strings)
      # SQL will only let you use ? to interpolate values,
      # not table or column names (e.g. in the FROM statement)
      info = DBConnection.execute2(<<-SQL)
      SELECT
      *
      FROM
      #{self.table_name}
      SQL
      @columns = info[0].map(&:to_sym)
    end
    @columns
  end

  def self.finalize!
    # Finalize is called at the end of the subclass definition to
    # add the getters/setters.
    self.columns.each do |col|
      # define_method takes a symbol as the argument
      define_method(col) { self.attributes[col] }
      # "#{:name}" == "name" String interpolation convert symbol to string
      define_method("#{col}=") { |val| self.attributes[col] = val }
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    # convert the array of Hash objects to an array of specific object
    # e.g. Cat object.
    # cannot call private method with explicit receiver
    parse_all(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL
    parse_all(results).first
  end

  # instance methods

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      # call ::columns on a class object, not the instance
      if self.class.columns.include?(attr_name)
        # avoid using @attributes or #attributes inside #initialize.
        self.send("#{attr_name}=", val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # use ::columns to ensure the order of attributes
    self.class.columns.map {|attr| self.send(attr) }
  end

  def insert
    # drop the first column to avoid inserting id
    columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(", ")
    question_marks = (["?"] * columns.count).join(", ")
    no_id_attr_array = attribute_values.drop(1)

    DBConnection.execute(<<-SQL, *no_id_attr_array)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    # drop the first column to avoid updating id
    # (the database should also take care of this)
    set_line = self.class.columns[1..-1]
      .map{ |attr_name| "#{attr_name} = ? "}.join(", ")

    id_at_last_array = attribute_values.rotate

    DBConnection.execute(<<-SQL, *id_at_last_array)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end

  private

  def self.parse_all(results)
    results.map{ |result| self.new(result) }
  end

end
