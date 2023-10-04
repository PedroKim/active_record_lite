require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)[0].map(&:to_sym)
      SELECT
        *
      FROM
        #{table_name}
    SQL
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      define_method("#{column}=") do |new_val|
        attributes[column] = new_val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  # def self.all
  #   results = DBConnection.execute(<<-SQL)
  #     SELECT
  #       *
  #     FROM
  #       #{table_name}
  #   SQL
  #   parse_all(results)
  # end

  def self.parse_all(results)
    results.map { |result| new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    parse_all(results)[0]
  end

  def initialize(params = {})
    params.each do |key, val|
      unless self.class.columns.include?(key.to_sym)
        raise "unknown attribute '#{key}'"
      end
      send("#{key}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| send(column) }
  end

  def insert
    col_names = self.class.columns.join(",")
    question_marks = (["?"] * self.class.columns.length).join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
    self
  end

  def update
    set_line = self.class.columns.map { |column| "#{column} = ?"}.join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = #{id}
    SQL
    self
  end

  def save
    id.nil? ? insert : update
  end
end
