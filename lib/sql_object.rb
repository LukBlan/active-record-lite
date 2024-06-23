require "active_support/core_ext/string"

class SqlObject
  def self.table_name
    @table_name ||= "Example"
  end

  def self.table_name=(table_name)
     @table_name = table_name
  end
end

class BigDog < SqlObject
end