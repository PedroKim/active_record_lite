require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_table_name = through_options.table_name
      source_options = through_options.model_class.assoc_options[source_name]
      source_table_name = source_options.table_name
      results = DBConnection.execute(<<-SQL, id)
        SELECT
          #{source_table_name}.*
        FROM
          #{through_table_name}
        JOIN
          #{source_table_name} 
          ON #{source_table_name}.id = #{through_table_name}.#{source_options.send(:foreign_key)}
        WHERE
          #{through_table_name}.id = ?
      SQL
      source_options.model_class.parse_all(results)[0]
    end
  end
  
end
