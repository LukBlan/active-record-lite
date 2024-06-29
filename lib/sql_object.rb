require "active_support/core_ext/string"
require_relative './services/db_connection'

class SqlObject
  def self.columns
    @columns ||= (DBConnection.connection.prepare(<<-SQL)
    SELECT
        *
    FROM
        #{self.table_name}
    SQL
    ).columns


  end

  def self.table_name
    @table_name ||= self.name.pluralize
  end

  def self.table_name=(table_name)
     @table_name = table_name
  end
end

class Person < SqlObject
end

# p Person.columns
