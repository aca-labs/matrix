# Generic, type-safe abstract matrix structure.
#
# This structure provides an *M* x *N* rectangular array of any
# [field](https://en.wikipedia.org/wiki/Field_(mathematics)) *T*. That is, *T*
# must define operations for addition, subtraction, multiplication and division.
#
# Where possible, all matrix operations provide validation at the type level.
struct Matrix(T, M, N)
  @buffer : Pointer(T)

  # Creates a Matrix with each element initialized as *value*.
  def self.of(value : T)
    Matrix(T, M, N).new { value }
  end

  # Creates a Matrix, invoking *initialiser* with each pair of indices.
  def self.from(&initialiser : UInt32, UInt32 -> T)
    Matrix(T, M, N).new do |idx|
      i = (idx / N).to_u32
      j = (idx % N).to_u32
      initialiser.call i, j
    end
  end

  # Creates Matrix, yielding the linear index for each element to provide an
  # initial value.
  def initialize(&block : Int32 -> T)
    {{ raise("Matrix dimensions must be positive") if M < 0 || N < 0 }}
    @buffer = Pointer(T).malloc(size, &block)
  end

  # Retrieves the value of the element at *i*,*j*.
  #
  # Indicies are zero-based. Negative values may be passed for *i* and *j* to
  # enable reverse indexing such that `self[-1, -1] == self[m - 1, n - 1]`
  # (same behaviour as arrays).
  def [](i : Int, j : Int) : T
    idx = index i, j
    @buffer[idx]
  end

  # Yields the current element at *i*,*j* and updates the value with the
  # block's return value.
  def update(i, j, &block : T -> T)
    idx = index i, j
    @buffer[idx] = yield @buffer[idx]
  end

  # Sets the value of the element at *i*,*j*.
  def []=(i : Int, j : Int, value : T)
    idx = index i, j
    @buffer[idx] = value
  end

  # Returns the dimensions of `self` as a tuple of {rows, cols}.
  def dimensions
    {M, N}
  end

  # Gets the capacity (total number of elements) of `self`.
  def size
    M * N
  end

  # Map *i*,*j* coords to an index within the buffer.
  private def index(i : Int, j : Int)
    i += M if i < 0
    j += N if j < 0

    raise IndexError.new if i < 0 || j < 0
    raise IndexError.new unless i < M && j < N

    i * N + j
  end
end
