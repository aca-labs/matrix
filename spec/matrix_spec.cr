require "spec"
require "../src/matrix"

describe Matrix do
  describe "initialization" do
    it "supports creation with a single, repeated value" do
      Matrix(Int32, 10, 10).of 42
    end

    it "supports creation with an indices initialiser" do
      Matrix(UInt32, 2, 2).build { |i, j| i * j }
    end

    it "supports building from a StaticArray" do
      a = StaticArray[1, 2, 3, 4]
      Matrix(Int32, 2, 2).from a
    end

    it "supports creation with a linear index initialiser" do
      Matrix(Int32, 2, 2).new { |idx| idx }
    end
  end

  describe "special matricies" do
    it "builds zero matrices" do
      Matrix(Int32, 2, 2).zero.should eq(Matrix(Int32, 2, 2).of 0)
    end

    it "build identity matrices" do
      id = Matrix(Int32, 2, 2).from StaticArray[1, 0, 0, 1]
      Matrix(Int32, 2, 2).identity.should eq(id)
    end
  end

  describe "#==" do
    it "return false for differently sized matrices" do
      a = Matrix(Nil, 10, 10).of nil
      b = Matrix(Nil, 5, 5).of nil
      (a == b).should eq(false)
    end

    it "uses element equality for equally size matrices" do
      a = Matrix(Int32, 10, 10).of 42
      b = Matrix(Float32, 10, 10).of 42.0
      (a == b).should eq(true)
    end

    it "return false for other objects" do
      a = Matrix(Nil, 10, 10).of nil
      (a == "Foo").should eq(false)
    end
  end

  describe "#+" do
    it "supports matrix addition" do
      a = Matrix(Int32, 2, 2).of 1
      b = Matrix(Int32, 2, 2).of 2
      (a + b).should eq(Matrix(Int32, 2, 2).of 3)
    end
  end

  describe "#-" do
    it "supports matrix subtraction" do
      a = Matrix(Int32, 2, 2).of 2
      b = Matrix(Int32, 2, 2).of 2
      (a - b).should eq(Matrix(Int32, 2, 2).of 0)
    end
  end

  describe "#*" do
    a = Matrix(Int32, 2, 2).of 1

    it "supports matrix multiplication" do
      id = Matrix(Int32, 2, 2).identity
      (a * id).should eq(a)
      (id * a).should eq(a)

      c = Matrix(Int32, 2, 3).new { |i| i + 1 }
      d = Matrix(Int32, 3, 2).new { |i| i + 7 }
      e = Matrix(Int32, 2, 2).from StaticArray[58, 64, 139, 154]
      (c * d).should eq(e)
    end

    it "supports scalar multiplication" do
      (a * 2).should eq(Matrix(Int32, 2, 2).of 2)
    end
  end

  describe "#[]" do
    a = Matrix(Int32, 5, 5).new { |idx| idx }

    it "supports retrieval based on row, column addresses" do
      a[0, 0].should eq(0)
      a[0, 4].should eq(4)
      a[1, 0].should eq(5)
    end

    it "support negative index lookups" do
      a[-1, -1].should eq(a[4, 4])
    end

    it "raises an index error for invalid indices" do
      expect_raises(IndexError) { a[10, 0] }
      expect_raises(IndexError) { a[-10, 0] }
    end
  end

  describe "#[]=" do
    a = Matrix(Int32, 5, 5).zero

    it "supports assigning new values to elements" do
      a[0, 0] = 42
      a[0, 0].should eq(42)
      a[0, 1].should eq(0)
    end
  end

  describe "#row" do
    a = Matrix(Int32, 2, 2).identity
    a.row(0).should eq(StaticArray[1, 0])
    a.row(1).should eq(StaticArray[0, 1])
  end

  describe "#col" do
    a = Matrix(Int32, 2, 2).identity
    a.col(0).should eq(StaticArray[1, 0])
    a.col(1).should eq(StaticArray[0, 1])
  end

  describe "#update" do
    a = Matrix(Int32, 10, 10).of 42

    it "yields the current value" do
      a.update(0, 0) do |x|
        x.should eq(42)
        x
      end
    end

    it "assigns the returned value to the element" do
      a.update(0, 0) { 1234 }
      a[0, 0].should eq(1234)
    end
  end

  describe "#map" do
    it "supports mapping to new contained type" do
      a = Matrix(Int32, 10, 10).zero
      b = a.map(&.to_f)
      b.all? { |x| typeof(x) == Float64 }.should be_true
    end
  end

  describe "#map!" do
    it "supports mutating self" do
      a = Matrix(Int32, 10, 10).of 42
      a.map!(&.*(2))
      a.all?(&.==(84)).should be_true
    end
  end

  describe "#transpose" do
    it "creates a transposed matrix" do
      a = Matrix(UInt32, 2, 3).build { |i, j| i * j }
      b = Matrix(UInt32, 3, 2).build { |i, j| j * i }
      a.transpose.should eq(b)
    end
  end

  describe "#dimensions" do
    it "provides the dimensions as a tuple" do
      a = Matrix(Nil, 10, 5).of nil
      a.dimensions.should eq({10, 5})
    end
  end

  describe "#size" do
    it "provides the total capacity" do
      a = Matrix(Nil, 10, 5).of nil
      a.size.should eq(50)
    end
  end

  describe "#rows" do
    it "provides the row count" do
      a = Matrix(Nil, 10, 5).of nil
      a.rows.should eq(10)
    end
  end

  describe "#cols" do
    it "provides the column count" do
      a = Matrix(Nil, 10, 5).of nil
      a.cols.should eq(5)
    end
  end
end
