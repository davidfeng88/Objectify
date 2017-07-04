require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject

  def self.columns

    if @columns.nil?
      info = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      @columns = info[0].map(&:to_sym)
    end

    @columns
    # solution: LIMIT 0
    # It can also be employed to obtain the types of the result columns
    # if you are using a MySQL API that makes result set metadata available.
  end

  def self.finalize!
    columns.each do |col|
      define_method(col.to_s) { attributes[col] }
      define_method("#{col.to_s}=") { |val| attributes[col] = val }
    end
  end
  # "#{:name}" == "name"

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
    # e.g. self is the Dog class. self.to_s and self.name both give "Dog" String
    # tableize = underscore * pluralize
    # @table_name = self.to_s.tableize if @table_name.nil?
    @table_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    @objects_array = self.parse_all(results)

  end

  def self.parse_all(results)
    array = []
    results.each do |row|
      el = self.new
      columns.each do |col|
        el.send("#{col.to_s}=", row[col])
      end
      array << el
    end
    # solution:
    # results.map{ |result| self.new(result) }

    array
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
    return nil if results.length == 0
    self.new(results[0])
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name.to_sym}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # @attributes.values
    self.class.columns.map {|el| self.send(el) }
  end

  def insert
    col_names = self.class.columns[1..-1].map(&:to_s).join(", ")
    question_marks = (["?"] * self.class.columns[1..-1].count).join(", ")
    no_id_attr_array = attribute_values[1..-1]

    DBConnection.execute(<<-SQL, *no_id_attr_array)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns[1..-1].map{ |attr_name| "#{attr_name} = ? "}.join(", ")

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
    if id.nil?
      insert
    else
      update
    end
    # solution
    # id.nil? ? insert : update
  end
end
