require 'pg'
require 'query_set'

# Connect to multiple databases.
db1 = PG::Connection.open(ENV['db1'])
db2 = PG::Connection.open(ENV['db2'])

# Initialize QuerySet with the appropriate connection.
users = QuerySet.new(db1, './sql/users/%s.sql')
posts = QuerySet.new(db2, './sql/posts/%s.sql')
