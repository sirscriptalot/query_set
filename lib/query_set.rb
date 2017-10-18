class QuerySet
  VERSION = '0.0.0'

  attr_accessor :conn, :path, :query, :store

  def initialize(conn, path, query: Query, store: {})
    @conn = conn
    @path = path
    @query = query
    @store = store
  end

  def [](file_name)
    store.fetch(file_name) do
      store[file_name] = query.new(File.read(path % file_name))
    end
  end

  def []=(key, value)
    store[key] = value
  end

  def execute(file_name, *args)
    self.[](file_name).execute(conn, *args)
  end

  class Query
    LEFT = '{{'

    RIGHT = '}}'

    attr_reader :sql, :params

    def initialize(str)
      @sql = ''
      @params = []

      compile(str)

      @sql.freeze
      @params.freeze
    end

    def execute(conn, args = {})
      conn.exec_params(sql, args.values_at(*params))
    end

    private

    def compile(str)
      terms = str.split(regexp)

      while (term = terms.shift)
        case term
        when left
          param = terms.shift.to_sym

          # Capture the param for execute position.
          params << param

          # Append a 1-based placeholder for the param to the sql string.
          sql << "$#{params.index(param).succ}"
        else
          sql << term
        end
      end

      # Only remember the unique parameters.
      params.uniq!
    end

    def left
      LEFT
    end

    def right
      RIGHT
    end

    def regexp
      /(#{left})\s*(.*?)\s*#{right}/
    end
  end
end
