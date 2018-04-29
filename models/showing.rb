require_relative '../db/sql_runner'

class Showing
  attr_accessor :capacity, :film_id
  attr_reader :id
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

  def self.delete_all
    sql = "DELETE FROM showings"
    SqlRunner.run sql
  end

  def self.read_all
    sql = "SELECT * FROM showings"
    results = SqlRunner.run sql
    build_results results, self
  end

  def date_time= date_string
    DateTime.strptime(date_string, DATE_TIME_FORMAT)
  end

  private
  def self.build_results results, type
    results.map{|hash| type.new(hash)}
  end
end
