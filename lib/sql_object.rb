require "active_support/core_ext/string"
require_relative './services/db_connection'

class SqlObject
  def self.find(id)
    query_result = DBConnection.connection.execute(<<-SQL, id: id)
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          id = :id
    SQL

    if query_result.empty?
      raise ArgumentError.new("Id don't exist in database")
    else
      return self.new(query_result[0])
    end
  end

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

  def initialize(hash)
    hash.each do |key, value|
      string_key = key.to_s
      raise ArgumentError.new("Invalid argument #{key} don't exist") if !self.class.columns.include?(string_key)
      send("#{string_key}=".to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def self.finalize!
    columns = self.columns

    columns.each do |column_name|
      define_method(column_name) do
        self.attributes
        @attributes[column_name]
      end

      define_method("#{column_name}=") do |value|
        self.attributes
        @attributes[column_name] = value
      end
    end
  end

  def self.all
    query_result = DBConnection.connection.execute(<<-SQL)
        SELECT
            *
        FROM
            #{self.table_name}
    SQL

    self.parse_all(query_result)
  end

  def self.parse_all(query_result)
    query_result.map { |result| self.new(result)}
  end
end

class Person < SqlObject
  self.finalize!
end

p Person.find(1)