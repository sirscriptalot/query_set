# You can "preprocess" your sql templates via string interpolation
# when working directly with QuerySet::Query.

# Unnecessary for trusted data, but always remember to escape user input.
# Be careful though, escaping user input is never guarenteed to be 100% safe.
column = conn.escape_string('column')

# Initialize a query with an interpolated string with escaped values.
by_column = QuerySet::Query.new("SELECT * FROM users WHERE #{column} = {{ column }};")

# Executing a query directly requires passing it your db connection.
by_column.execute(conn, column: 'value')

# You can also assign a query to an existing query set.
query_set['by_column'] = by_column
