require_relative './assoc_options'

module Associatable
  def associations
    @associations ||= {}
  end

  def has_many(association_name, **optional_hash)
    associations[association_name] = HasManyOptions.new(association_name, **optional_hash)
  end

  def belongs_to(association_name, **optional_hash)
    associations[association_name] = BelongsTo.new(association_name, **optional_hash)
  end

  def join(association_name)
    associationOption = @associations[association_name]
    class_table = self.table_name.downcase
    association_class = associationOption.class_name

    association_table = Object.const_get(association_class).table_name.downcase
    primary_key = associationOption.primary_key
    foreign_key = associationOption.foreign_key

    query = <<-SQL
        SELECT
          #{association_table}.*
        FROM
            #{class_table}
        JOIN
            #{association_table} ON #{class_table}.#{primary_key} = #{association_table}.#{foreign_key}
    SQL

    p query
    query_result = DBConnection.connection.execute(query)
    Object.const_get(association_class).parse_all(query_result)
  end
end