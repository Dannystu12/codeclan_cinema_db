require_relative "../db/sql_runner"

class Customer
  attr_accessor :name, :funds
  attr_reader :id

  TABLE_NAME = "customers"

  def initialize options
    @id = options["id"].to_i if options["id"]
    @name = options["name"]
    @funds = options["funds"].to_f
  end

  def create
    sql = SqlRunner.build_create TABLE_NAME, ["name", "funds"], ["id"]
    result = SqlRunner.run sql, [@name, @funds]
    @id = result[0]["id"].to_i
  end

  def update


  end

  def delete
  end

  def self.read_all
  end

  def self.delete_all
  end

  def self.find_name name
  end

  def self.find_id id
  end
end
