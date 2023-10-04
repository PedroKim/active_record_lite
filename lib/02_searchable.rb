require_relative 'db_connection'
require_relative '01_sql_object'

class Relation
  attr_reader :table_name, :model_class, :params, :sql_result

  def initialize(table_name, model_class, params, sql_result = [])
    @table_name, @model_class, @params = table_name, model_class, params
    @sql_result = sql_result
  end

  def where(extra_params)
    extra_params.each { |key, val| params[key] = val }
    execute_sql
    self
  end

  def execute_sql
    where_line = params.keys.map { |key| "#{key} = ?"}.join(" AND ")
    results = DBConnection.execute(<<-SQL, *(params.values))
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
    @sql_result = model_class.parse_all(results)
    self
  end

  def [](idx)
    @sql_result[idx]
  end

end

module Searchable
  def all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    Relation.new(table_name, self, {}, parse_all(results))
  end

  def where(params)
    Relation.new(table_name, self, params, []).execute_sql
  end
end

class SQLObject
  extend Searchable
end
