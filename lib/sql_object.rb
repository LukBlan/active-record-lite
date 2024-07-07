require "active_support/core_ext/string"
require_relative './services/db_connection'
require_relative 'searchable'
require_relative './associations/associable'

class SqlObject
  extend Searchable
  extend Associatable

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

  def update
    id = @attributes["id"]
    raise ArgumentError("Missing record in database") if id.nil?
    filter_columns = self.class.columns.filter { |column| column != "id"}

    map_attributes = filter_columns.map do |key|
      value = @attributes[key]
      final_value = value.is_a?(String) ? "'#{value}'" : value
      "#{key} = #{final_value}"
    end

    DBConnection.connection.execute(<<-SQL
        UPDATE
            #{self.class.table_name}
        SET
          #{map_attributes.join(",")}
        WHERE
          id = #{id}
    SQL
    )
  end

  def save
    id = @attributes["id"]

    if id.nil?
      insert
    else
      update
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

class Animal < SqlObject
  has_many :toys, foreign_key: :owner_id, class_name: :Toy
  self.finalize!
end

class Toy < SqlObject
  belongs_to :owner, foreign_key: :owner_id, class_name: :Animal
  self.finalize!
end



p Toy.join(:owner)
