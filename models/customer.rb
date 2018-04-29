require_relative "../db/sql_runner"

class Customer
  attr_accessor :name, :funds
  attr_reader :id

  def initialize options
    @id = options["id"].to_i if options["id"]
    @name = options["name"]
    @funds = options["funds"].to_f
  end

  def create
    sql = "INSERT INTO customers(name, funds) VALUES($1, $2) RETURNING id"
    result = SqlRunner.run sql, [@name, @funds]
    @id = result[0]["id"].to_i
  end

  def update
    sql = "UPDATE customers SET(name, funds) = ($1, $2) WHERE id = $3"
    SqlRunner.run sql, [@name, @funds, @id]
  end

  def delete
    sql = "DELETE FROM customers WHERE id = $1"
    SqlRunner.run sql, [@id]
  end

  def get_films
    Ticket.get_films_by_customer @id
  end

  def can_afford? value
    @funds >= value
  end

  def pay value
    return unless can_afford? value
    @funds -= value
    update
  end

  def refresh
    this_customer = self.class.find_id @id
    @name = this_customer.name
    @funds = this_customer.funds
  end

  def self.read_all
    sql = "SELECT * FROM customers"
    results = SqlRunner.run sql
    build_results(results, self)
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run sql
  end

  def self.find_name name
    sql = "SELECT * FROM customers WHERE name = $1 LIMIT 1"
    results = SqlRunner.run sql, [name]
    build_results(results, self).first
  end

  def self.find_id id
    sql = "SELECT * FROM customers WHERE id = $1"
    results = SqlRunner.run sql, [id]
    build_results(results, self).first
  end

  private
  def self.build_results results, type
    results.map{|hash| type.new(hash)}
  end
end
