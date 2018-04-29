require_relative '../db/sql_runner'

class Ticket
  attr_accessor :customer_id, :showing_id
  attr_reader :id

  def initialize options
    @id = options["id"].to_i if options["id"]
    @customer_id = options["customer_id"].to_i
    @showing_id = options["showing_id"].to_i
  end

  def create
    showing = Showing.find_id @showing_id
    return unless showing.has_capacity?
    customer = Customer.find_id @customer_id
    return unless customer.can_afford?(showing.get_price)
    customer.pay(showing.get_price)
    sql = "INSERT INTO tickets(customer_id, showing_id) VALUES($1, $2) RETURNING id"
    results = SqlRunner.run sql, [@customer_id, @showing_id]
    @id = results[0]["id"].to_i
  end

  def update
    current_ticket = self.class.find_id @id
    old_showing = Showing.find_id(current_ticket.showing_id)
    old_customer = Customer.find_id(current_ticket.customer_id)
    new_showing = Showing.find_id(@showing_id)
    new_customer = Customer.find_id(@customer_id)

    unless old_showing.id == new_showing.id
      return unless new_showing.has_capacity?
    end

    old_customer.refund old_showing.get_price # refund original customer
    new_customer.refresh #refresh new customer in case it is the same as old

    unless new_customer.can_afford?(new_showing.get_price)
      old_customer.pay old_showing.get_price
      warn "Could not update ticket as customer #{new_customer.id} could not afford showing #{new_showing.id}"
      return
    end

    new_customer.pay(new_showing.get_price)
    sql = "UPDATE tickets SET(customer_id, showing_id) = ($1, $2) WHERE id = $3"
    SqlRunner.run sql, [@customer_id, @showing_id, @id]
  end

  def delete
    customer = Customer.find_id customer_id
    showing = Showing.find_id showing_id
    customer.refund(showing.get_price)
    sql = "DELETE FROM tickets WHERE id = $1"
    SqlRunner.run sql, [@id]
  end

  def refresh
    this_ticket = self.class.find_id @id
    @customer_id = this_ticket.customer_id
    @showing_id = this_ticket.showing_id
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

  def self.get_showings_by_customer customer_id
    sql = "SELECT * FROM tickets WHERE customer_id = $1"
    results = SqlRunner.run sql, [customer_id]
    tickets = build_results(results, self)
    tickets.map{|ticket| Showing.find_id(ticket.showing_id)}
  end

  def self.get_customers_by_showing showing_id
    sql = "SELECT * FROM tickets WHERE showing_id = $1"
    results = SqlRunner.run sql, [showing_id]
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
