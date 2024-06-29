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
end

class Person < SqlObject
  self.finalize!
end

person = Person.new({name: "Lucas"})
p person.attributes