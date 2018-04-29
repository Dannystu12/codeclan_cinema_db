require_relative '../db/sql_runner'

class Ticket
  attr_accessor :customer_id, :film_id
  attr_reader :id

  def initialize options
    @id = options["id"].to_i if options["id"]
    @customer_id = options["customer_id"].to_i
    @film_id = options["film_id"].to_i
  end

  def create
    sql = "INSERT INTO tickets(customer_id, film_id) VALUES($1, $2) RETURNING id"
    results = SqlRunner.run sql, [@customer_id, @film_id]
    @id = results[0]["id"].to_i
  end

  def update
    sql = "UPDATE tickets SET(customer_id, film_id) = ($1, $2) WHERE id = $3"
    SqlRunner.run sql, [@customer_id, @film_id, @id]
  end

  def delete
    sql = "DELETE FROM tickets WHERE id = $1"
    SqlRunner.run sql, [@id]
  end

  def self.read_all
    sql = "SELECT * FROM tickets"
    results = SqlRunner.run sql
    build_results results, self
  end

  def self.delete_all
    sql = "DELETE FROM tickets"
    SqlRunner.run sql
  end

  def self.get_films_by_customer customer_id
    sql = "SELECT * FROM tickets WHERE customer_id = $1"
    results = SqlRunner.run sql, [customer_id]
    tickets = build_results(results, self)
    tickets.map{|ticket| Film.find_id(ticket.film_id)}
  end

  def self.get_customers_by_film film_id
    sql = "SELECT * FROM tickets WHERE film_id = $1"
    results = SqlRunner.run sql, [film_id]
    tickets = build_results(results, self)
    tickets.map{|ticket| Customer.find_id(ticket.customer_id)}
  end

  def self.find_id id
    sql = "SELECT * FROM tickets WHERE id = $1"
    results = SqlRunner.run sql, [id]
    build_results(results, self).first
  end

  private
  def self.build_results results, type
    results.map{|hash| type.new(hash)}
  end
end
