module Searchable
  def where(hash)
    mapped_hash = hash.map do |key, value|
      final_value = value.is_a?(String) ? "'#{value}'" : value

      "#{key.to_s} = #{final_value}"
    end.join(" AND ")


    query = <<-SQL
        SELECT
            *
        FROM
            #{self.table_name}
        WHERE
          #{mapped_hash}
    SQL

    result = DBConnection.connection.execute(query)

    self.parse_all(result)
  end
end
