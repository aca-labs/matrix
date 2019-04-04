# Generic, type-safe abstract matrix structure.
#
# This structure provides an *M* x *N* rectangular array of any
# [field](https://en.wikipedia.org/wiki/Field_(mathematics)) *T*. That is, *T*
# must define operations for addition, subtraction, multiplication and division.
#
# Where possible, all matrix operations provide validation at the type level.
struct Matrix(T, M, N)
  include Indexable(T)

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

  # Creates a Matrix from elements contained within a StaticArray.
  #
  # The matrix will be filled rows first, such that an array of
  #
  #   [1, 2, 3, 4]
  #
  # becomes
  #
  #   | 1  2 |
  #   | 3  4 |
  #
  def self.from(list : StaticArray(T, A))
    {{ raise("Not enough elements to fill matrix") if A < M * N }}

    Matrix(T, M, N).new do |idx|
      list[idx]
    end
  end

  # Build a zero matrix (all elements populated with zero value of the type
  # isntance).
  def self.zero
      Matrix(T, N, M).new { T.zero }
  end

  # Build the idenity matrix for the instanced type and dimensions.
  #
  # `id` may be used to specify an identity element for the type. If unspecifed
  # a numeric identity will be assumed.
  def self.identity(id = T.zero + 1)
    {{ raise("Matrix dimensions must be square") unless M == N }}

    Matrix(T, N, M).from do |i, j|
      i == j ? id : T.zero
    end
  end

  # Creates Matrix, yielding the linear index for each element to provide an
  # initial value.
  def initialize(&block : Int32 -> T)
    {{ raise("Matrix dimensions must be positive") if M < 0 || N < 0 }}
    @buffer = Pointer(T).malloc(size, &block)
  end

  # Equality. Returns `true` if each element in `self` is equal to each
  # corresponding element in *other*.
  def ==(other : Matrix(U, A, B)) forall U
    {% if A == M && B == N %}
      each_with_index do |e, i|
        return false unless e == other[i]
      end
      true
    {% else %}
      false
    {% end %}
  end

  # Equality with another object, or differently sized matrix. Always `false`.
  def ==(other)
    false
  end

  # Returns a new Matrix that is the result of performing a matrix addition with
  # *other*
  def +(other : Matrix)
    merge(other) { |a, b| a + b }
  end

  # Returns a new Matrix that is the result of performing a matrix subtraction
  # with *other*
  def -(other : Matrix)
    merge(other) { |a, b| a - b }
  end

  # Retrieves the value of the element at *i*,*j*.
  #
  # Indicies are zero-based. Negative values may be passed for *i* and *j* to
  # enable reverse indexing such that `self[-1, -1] == self[M - 1, N - 1]`
  # (same behaviour as arrays).
  def [](i : Int, j : Int) : T
    idx = index i, j
    to_unsafe[idx]
  end

  # Sets the value of the element at *i*,*j*.
  def []=(i : Int, j : Int, value : T)
    idx = index i, j
    to_unsafe[idx] = value
  end

  # Yields the current element at *i*,*j* and updates the value with the
  # block's return value.
  def update(i, j, &block : T -> T)
    idx = index i, j
    to_unsafe[idx] = yield to_unsafe[idx]
  end

  # Apply a morphism to all elements, returning a new Matrix with the result.
  def map(&block : T -> U) forall U
    Matrix(U, M, N).new do |idx|
      block.call to_unsafe[idx]
    end
  end

  # ditto
  def map_with_indices(&block : T, UInt32, UInt32 -> U) forall U
    Matrix(U, M, N).from do |i, j|
      block.call self[i, j], i, j
    end
  end

  # ditto
  def map_with_index(&block : T, Int32 -> U) forall U
    Matrix(U, M, N).new do |idx|
      block.call to_unsafe[idx], idx
    end
  end

  # Apply an endomorphism to `self`, mutating all elements in place.
  def map!(&block : T -> T)
    each_with_index do |e, idx|
      to_unsafe[idx] = yield e
    end
    self
  end

  def merge(other : Matrix(U, A, B), &block : T, U -> _) forall U
    {{ raise("Dimension mismatch") unless  A == M && B == N }}

    map_with_index do |e, i|
      block.call e, other[i]
    end
  end

  # Returns the dimensions of `self` as a tuple of `{rows, cols}`.
  def dimensions
    {M, N}
  end

  # Gets the capacity (total number of elements) of `self`.
  def size
    M * N
  end

  # Count of rows.
  def rows
    M
  end

  # Count of columns.
  def cols
    N
  end

  # Returns the element at the given linear index, without doing any bounds
  # check.
  #
  # Used by `Indexable`
   @[AlwaysInline]
  protected def unsafe_fetch(index : Int)
    to_unsafe[index]
  end

  # Returns the pointer to the underlying element data.
  protected def to_unsafe : Pointer(T)
    @buffer
  end

  # Map *i*,*j* coords to an index within the buffer.
  protected def index(i : Int, j : Int)
    i += rows if i < 0
    j += cols if j < 0

    raise IndexError.new if i < 0 || j < 0
    raise IndexError.new unless i < rows && j < cols

    i * N + j
  end
end
