test '#compile replaces identifiers with ordered placeholders' do
  query = QuerySet::Query.new('{{ first }} {{ second }} {{ first }}')

  assert_equal query.sql, '$1 $2 $1'
end

test '#compile captures unique params' do
  query = QuerySet::Query.new('{{ first }} {{ second }} {{ first }}')

  assert_equal query.params, [:first, :second]
end

test '#compile ignores whitespace in identifiers' do
  a = QuerySet::Query.new('{{first}} {{second}} {{first}}')
  b = QuerySet::Query.new('{{ first }} {{ second }} {{ first }}')

  assert_equal a.sql, b.sql
end

class FakeConn
  attr_reader :sql, :ary

  def exec_params(sql, ary)
    @sql, @ary = sql, ary
  end
end

test '#execute delegates to conn with correct parameters order' do
  conn = FakeConn.new

  query = QuerySet::Query.new('{{ first }} {{ second }} {{ first }}')

  args = { second: 2, first: 1}

  query.execute(conn, args)

  assert_equal conn.sql, query.sql
  assert_equal conn.ary, [1, 2]
end
