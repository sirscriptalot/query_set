setup do
  query_set = QuerySet.new(nil, __dir__ + "/sql/%s.sql")
end

test '#[] initializes query objects for path/file_name' do |query_set|
  query = query_set['example']

  assert query.is_a?(query_set.query)
end

test '#[] memoizes query objects' do |query_set|
  a = query_set['example']
  b = query_set['example']

  assert_equal a.object_id, b.object_id
end

test '#[]= sets query objects' do |query_set|
  query_set['foo'] = 'bar'

  assert_equal query_set['foo'], 'bar'
end

class FakeQuery
  attr_reader :conn, :args

  def initialize(*args); end

  def execute(conn, args)
    @conn, @args = conn, args
  end
end

test '#execute sends conn and args to query object for file name' do
  conn = :conn

  args = { foo: :bar }

  query_set = QuerySet.new(conn, __dir__ + "/sql/%s.sql", query: FakeQuery)

  query_set.execute('example', args)

  query = query_set['example']

  assert_equal query.conn, conn
  assert_equal query.args, args
end
