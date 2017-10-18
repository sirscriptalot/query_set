# Custom delimiters can be set for compiling templates by subclassing
# QuerySet::Query.

require 'pg'
require 'query_set'

class Query < QuerySet::Query
  # Override the left and right delimiter methods
  # to build a custom regexp for compiling templates.
  def left
    '<%='
  end)

  def right
    '%>'
  end
end

# Inject your subclass when you initializing the QuerySet.
QuerySet.new(conn, '', query: Query)
