require 'sqlite3'

class DBConnection
  def self.create_connection(db_name)
    @connection = SQLite3::Database.new db_name
    @connection.results_as_hash =
      @connection
  end

  def self.connection
    @connection
  end

  create_connection "./../active_record_db.sqlite"
end
