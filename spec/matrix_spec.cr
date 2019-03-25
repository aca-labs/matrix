require "./spec_helper"

describe Matrix do
  describe "initialization" do
    it "supports creation with a single, repeated value" do
      Matrix(Int32, 10, 10).of(42)
    end

    it "supports creation with an indices initialiser" do
      Matrix(UInt32, 2, 2).from { |i, j| i * j }
    end

    it "supports creation with a linear index initialiser" do
      Matrix(Int32, 2, 2).new { |idx| idx }
    end
  end
end
