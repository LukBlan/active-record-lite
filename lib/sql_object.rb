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
    @attributes ||= {"id" => nil}
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

  def insert
    map_keys = @attributes.keys.join(",")
    map_attributes = @attributes.values.map do |value|
      if value.is_a?(String)
        "'#{value}'"
      elsif value.nil?
        "NULL"
      else
        value
      end
    end.join(",")

    DBConnection.connection.execute(<<-SQL)
        INSERT INTO
            #{self.class.table_name} (#{map_keys})
        VALUES (#{map_attributes})  
    SQL

    @attributes["id"] = DBConnection.connection.last_insert_row_id
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

person = Person.new(name: "Tomas", surname: "Aurilio", age: 100)
person.insert
p person