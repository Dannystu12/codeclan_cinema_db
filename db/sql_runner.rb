require 'pg'
class SqlRunner
  DB_NAME = "codeclan_cinema"
  HOST = "localhost"
  def self.run sql, values
    begin
      db = PG.connect({dbname: DB_NAME, host: HOST})
      db.prepare "query", sql
      results = db.exec_prepared "query", values
    ensure
      db.close if db
    end
    results
  end

  def self.build_create table, columns, returning=nil
    r = returning ? "RETURNING #{delimit(returning)}" : ""
    v = columns.map.with_index{|_, i| "$#{i+1}"}
    "INSERT INTO #{table}(#{delimit(columns)}) VALUES(#{delimit(v)}) #{r}"
  end

  private
  def self.delimit array
    array.join(', ')
  end

end
