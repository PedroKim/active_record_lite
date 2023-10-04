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
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    self.class_name = options[:class_name] || name.to_s.camelcase
    self.primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    self.class_name = options[:class_name] || name.to_s.singularize.camelcase
    self.primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key_val = send(options.send(:foreign_key))
      where_hash = {}
      where_hash[options.send(:primary_key)] = foreign_key_val
      options.model_class.where(where_hash)[0]
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    assoc_options[name] = options
    define_method(name) do
      primary_key_val = send(options.send(:primary_key))
      where_hash = {}
      where_hash[options.send(:foreign_key)] = primary_key_val
      options.model_class.where(where_hash)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
