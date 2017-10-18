# Below is an example on how to implement a poor man's ORM with the
# active record pattern using QuerySet. If something like this interests you,
# check out the 'MiniModel' gem at https://github.com/sirscriptalot/mini_model.

require 'pg'
require 'query_set'

class Model
  class << self
    attr_accessor :query_set

    def [](id)
      result = query_set.execute('by_id', id: id)

      build(result)
    rescue PG::Error => e
      puts e

      nil
    end

    alias_method :by_id, :[]

    def build(result)
      # ...
    end
  end
end

conn = PG::Connection.open(ENV['db1'])

User.query_set = QuerySet.new(conn, './sql/users/%s.sql')

User[0]
