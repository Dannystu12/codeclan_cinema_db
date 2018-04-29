require_relative '../db/sql_runner'

class Film
  attr_accessor :title, :price
  attr_reader :id

  def initialize options
    @id = options["id"].to_i if options["id"]
    @title = options["title"]
    @price = options["price"].to_f
  end

  def create
    sql = "INSERT INTO films(title, price) VALUES($1, $2) RETURNING id"
    result = SqlRunner.run sql, [@title, @price]
    @id = result[0]["id"].to_i
  end

  def update
    sql = "UPDATE films SET(title, price) = ($1, $2) WHERE id = $3"
    SqlRunner.run sql, [@title, @price, @id]
  end

  def delete
    sql = "DELETE FROM films WHERE id = $1"
    SqlRunner.run sql, [@id]
  end

  def get_customers
    Ticket.get_customers_by_film @id
  end

  def customer_count
    get_customers.count
  end

  def refresh
    this_film = find_id @id
    @title = this_film.name
    @price = this_film.price
  end

  def self.read_all
    sql = "SELECT * FROM films"
    results = SqlRunner.run sql
    build_results(results, self)
  end

  def self.delete_all
    sql = "DELETE FROM films"
    SqlRunner.run sql
  end

  def self.find_title title
    sql = "SELECT * FROM films WHERE title = $1 LIMIT 1"
    results = SqlRunner.run sql, [title]
    build_results(results, self).first
  end

  def self.find_id id
    sql = "SELECT * FROM films WHERE id = $1"
    results = SqlRunner.run sql, [id]
    build_results(results, self).first
  end

  private
  def self.build_results results, type
    results.map{|hash| type.new(hash)}
  end

end
