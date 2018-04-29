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
    film = Film.find_id @film_id
    customer = Customer.find_id @customer_id
    return unless customer.can_afford?(film.price)
    customer.pay(film.price)
    sql = "INSERT INTO tickets(customer_id, film_id) VALUES($1, $2) RETURNING id"
    results = SqlRunner.run sql, [@customer_id, @film_id]
    @id = results[0]["id"].to_i
  end

  def update
    current_ticket = self.class.find_id @id
    old_film = Film.find_id(current_ticket.film_id)
    old_customer = Customer.find_id(current_ticket.customer_id)
    new_film = Film.find_id(@film_id)
    new_customer = Customer.find_id(@customer_id)
    old_customer.refund old_film.price # refund original customer
    new_customer.refresh #refresh new customer in case it is the same as old

    unless new_customer.can_afford? new_film.price
      old_customer.pay old_film.price
      warn "Could not update ticket as customer #{new_customer.id} could not afford film #{new_film.id}"
      return
    end

    new_customer.pay(new_film.price)
    sql = "UPDATE tickets SET(customer_id, film_id) = ($1, $2) WHERE id = $3"
    SqlRunner.run sql, [@customer_id, @film_id, @id]
  end

  def delete
    sql = "DELETE FROM tickets WHERE id = $1"
    SqlRunner.run sql, [@id]
  end

  def refresh
    this_ticket = self.class.find_id @id
    @customer_id = this_ticket.customer_id
    @film_id = this_ticket.film_id
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
