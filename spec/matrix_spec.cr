require "./spec_helper"

describe Matrix do
  describe "initialization" do
    it "supports creation with a single, repeated value" do
      Matrix(Int32, 10, 10).of 42
    end

    it "supports creation with an indices initialiser" do
      Matrix(UInt32, 2, 2).from { |i, j| i * j }
    end

    it "supports creation with a linear index initialiser" do
      Matrix(Int32, 2, 2).new { |idx| idx }
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
    a = Matrix(Int32, 5, 5).of 0

    it "supports assigning new values to elements" do
      a[0, 0] = 42
      a[0, 0].should eq(42)
      a[0, 1].should eq(0)
    end
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
end
