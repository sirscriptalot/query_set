# QuerySet

QuerySet is a small wrapper around the Ruby pg gem for safely executing
sql that is saved in files.

## Installation

`$ gem install query-set`

## API

### QuerySet

`initialize` Requires a connection and a formattable directory path.
Optional arguments include `query:` for setting the query class, and `store:`
for setting the caching object.

`[]` Fetches a query object from the cache (store). If it does not exist, loads
the corresponding template from disk and compiles it.

`[]=` Manually sets an object in the cache.

`execute` Delegates execution to the appropriate query object, passing it the configured
connection and any provided arguments.

### Query

`initialize` Requires a string to be compiled into a sql string with ordered
placeholders.

`execute` Sends sql to the connection for the given arguments.

## Usage

To get an understanding of QuerySet (qs), we're going to start from the bottom
and build our way up. The foundation of qs is the class QuerySet::Query.

QuerySet::Query is responsible for parsing a template string,
and converting it into a sql string with position based placeholders that
Postgres understands. This buys us two things. First, we "upgrade" our coupling
from one that is based on position to one that is based on name
(which is generally a good thing, see [connascence][Connascence]). The second
thing we get is security, since we no longer have to be escaping sql strings
manually we get to avoid all sorts of vulnerabilities. If you ever find yourself
using QuerySet::Query manually, remember to always escape any untrusted values
via `PG::Connection.escape_string`.

```ruby
  ## Initial a new query object.
  query = QuerySet::Query.new("SELECT * FROM users WHERE id = {{ id }} LIMIT 1;")

  ## During initialization, the query object
  ## 'compiled' the template string into a sql string.
  query.sql ## SELECT * FROM users WHERE id = $1 LIMIT 1;

  ## It also remembered the params (as symbols).
  query.params ## [:id]
```

Now that we have converted the template string into sql that our database
understands, we can execute it. To do so we send our query object
`##execute(conn, args)`.

The first argument, `conn`, is expected to be a `PG::Connection`.
The second argument is typically a `Hash`,
though you can pass it custom objects that implement `##values_at` (quick quick).

This means that `##execute` knows how to put our args in order
and then delegate the execution to the connection. The return values are the
same as using the `pg` gem directly: `PG::Result` on success, and
on a failure it raises `PG::Error`.

You're probably thinking this is a little inconvenient, having to pass the conn
in each time. But don't worry, this is handled for you by the `QuerySet` class.

The QuerySet class is the top level of the library, and is basically a
factory for your query objects your query objects. It is responsible for:

* Holding a reference to your database connection.
* Dealing with the file system.
* Caching query objects (not the results, just the compiled templates).
* Delegating execute to the the appropriate query object.

```ruby
  conn = PG.connection.open(ENV['pg'])

  ## Construct a QuerySet by giving it a reference to your connection
  ## and also a path where it can find your query templates.
  ## Notice the `%s` in the path, it's super important.
  ## When we call methods on our query set, we will send it the file name
  ## of our query. This file name serves as both the cache key for a query
  ## an it's location on disk.
  query_set = QuerySet.new(conn, './path/to/queries/%s.sql')

  ## To execute a query located in the directory we configured, we send it
  ## '##execute'.
  query_set.execute('users/by_id', id: id)

  ## This is the meat of the entire library. The first thing the execute method
  ## does is check the cache to see if a query object exists for the file
  ## name we gave it. If it does not exist, it creates one by giving QuerySet::Query
  ## the template string it finds on disc. Once the template is compiled, we
  ## get to hop back on the branch as if it was a cache hit. On a cache hit,
  ## we send our query object the `##execute` method, passing it the conn we have
  ## a reference to and also the supplied arguments.
```

Check out the examples directory and tests to get an even better understand
on how to use QuerySet.

[connascence][https://www.youtube.com/watch?v=HQXVKHoUQxY]
