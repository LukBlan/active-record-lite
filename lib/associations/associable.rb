require_relative './assoc_options'

module Associatable
  def associations
    @associations ||= {}
  end

  def has_many(association_name, **optional_hash)
    associations[association_name] = HasManyOptions.new(association_name, **optional_hash)

    define_method association_name do
      self.class.join(association_name, self)
    end
  end

  def belongs_to(association_name, **optional_hash)
    associations[association_name] = BelongsTo.new(association_name, **optional_hash)

    define_method association_name do
      self.class.join(association_name, self)
    end
  end

  def join(association_name, object=nil)
    associationOption = @associations[association_name]
    class_table = self.table_name.downcase
    association_class = associationOption.class_name

    association_table = Object.const_get(association_class).table_name.downcase
    primary_key = associationOption.primary_key
    foreign_key = associationOption.foreign_key

    where_clause = <<-SQL
        WHERE
            #{class_table}.id = #{object.get_id}
    SQL

    query = <<-SQL
        SELECT
          #{association_table}.*
        FROM
            #{class_table}
        JOIN
            #{association_table} ON #{class_table}.#{primary_key} = #{association_table}.#{foreign_key}
        #{object != nil ? where_clause : ""}
    SQL

    query_result = DBConnection.connection.execute(query)
    Object.const_get(association_class).parse_all(query_result)
  end
end