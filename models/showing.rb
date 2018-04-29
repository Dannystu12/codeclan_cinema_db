require_relative '../db/sql_runner'

class Showing
  attr_accessor :capacity, :film_id
  attr_reader :id, :date_time

  DATE_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

  def initialize options
    @id = options["id"].to_i if options["id"]
    @capacity = options["capacity"].to_i
    @film_id = options["film_id"].to_i
    @date_time = DateTime.strptime(options["date_time"], DATE_TIME_FORMAT)
  end

  def create
    sql = "INSERT INTO showings(capacity, film_id, date_time) VALUES($1, $2, $3) RETURNING id"
    results = SqlRunner.run sql, [@capacity, @film_id, @date_time]
    @id = results[0]["id"].to_i
  end

  def date_time= date_string
    DateTime.strptime(date_string, DATE_TIME_FORMAT)
  end

  def get_price
    Film.find_id(film_id).price
  end

  def self.find_id id
    sql = "SELECT * FROM showings WHERE id = $1"
    results = SqlRunner.run sql, [id]
    build_results(results, self).first
  end

  def self.delete_all
    sql = "DELETE FROM showings"
    SqlRunner.run sql
  end

  def self.read_all
    sql = "SELECT * FROM showings"
    results = SqlRunner.run sql
    build_results results, self
  end

  def self.get_showings_by_film film_id
    sql = "SELECT * FROM showings WHERE film_id = $1"
    results = SqlRunner.run sql, [film_id]
    build_results results, self
  end

  def self.get_most_popular_showing film_id
    sql = "SELECT showings.id, COUNT(tickets.id) AS c
    FROM showings JOIN tickets ON showings.id = tickets.showing_id
    WHERE showings.film_id = $1
    GROUP BY showings.id
    ORDER BY c DESC"
    results = SqlRunner.run sql, [film_id]
    find_id(results[0]["id"])
  end

  private
  def self.build_results results, type
    results.map{|hash| type.new(hash)}
  end
end
