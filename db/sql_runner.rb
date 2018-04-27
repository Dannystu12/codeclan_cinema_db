require 'pg'
class SqlRunner
  DB_NAME = "codeclan_cinema"
  HOST = "localhost"
  def self.run sql, values=[]
    begin
      db = PG.connect({dbname: DB_NAME, host: HOST})
      db.prepare "query", sql
      results = db.exec_prepared "query", values
    ensure
      db.close if db
    end
    results
  end

end
