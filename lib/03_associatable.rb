require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.constantize.table_name
    # solution:
    # model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # name is a symbol
    default = {
      primary_key: :id,
      foreign_key: "#{name.to_s}_id".to_sym,
      class_name: name.to_s.camelcase
    }

    options = default.merge(options)
    # merge: the hash as the argument has the priority

    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]

    # solution:
    # defaults.keys.each do |key|
    #   self.send("#{key}=", options[key] || defaults[key])
    # end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # name is a symbol
    default = {
      primary_key: :id,
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      class_name: name.to_s.singularize.camelcase
    }
    # solution: #underscore
    options = default.merge(options)

    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]

    # solution:
    # defaults.keys.each do |key|
    #   self.send("#{key}=", options[key] || defaults[key])
    # end

  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)
    # name = ":human"
    define_method(name) {
      foreign_key_value = self.send(self.class.assoc_options[name].foreign_key)
      # options.model_class: Human
      self.class.assoc_options[name].model_class.where(self.class.assoc_options[name].primary_key => foreign_key_value).first

    }

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    # this should also be updated with assoc_options!!
    # two steps:
    # 1. change options = to assoc_options[name] =
    # 2. change options. to self.class.assoc_options[name]
    # name = ":cats"
    define_method(name) {
      primary_key_value = self.send(options.primary_key)
      # options.model_class: Cat
      options.model_class.where(options.foreign_key => primary_key_value)

    }
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
