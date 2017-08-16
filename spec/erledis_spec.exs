defmodule ErledisSpec do
  use ESpec

  before do: Erledis.start_link

  describe "set" do
    context "correct key" do
      it do
        Erledis.set("hello", "word")
        expect(Erledis.exists?("hello")) |> to(be_true())
        expect(Erledis.get("hello")) |> to(eq "word")
      end
      it do
        Erledis.set("tuple", {1,2,3})
        expect(Erledis.exists?("tuple")) |> to(be_true())
        expect(Erledis.get("tuple")) |> to(eq {1,2,3})
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.set(1, 2)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.set([1], 2)) |> to(eq "key argument must be a string")
    end
  end

  describe "get" do
    before do
      Erledis.set("hello", "word")
      Erledis.set("list", [1,2,3])
    end

    context "value by key" do
      it do: expect(Erledis.get("hello")) |> to(eq "word")
      it do: expect(Erledis.get("list")) |> to(eq [1,2,3])
    end

    context "element with incorrect key" do
      it do: expect(Erledis.get(1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.get([1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.get("atom")) |> to(eq nil)
      it do: expect(Erledis.get("string")) |> to(eq nil)
    end
  end

  describe "delete" do
    before do
      Erledis.set("hello", "word")
      Erledis.set("list", [1,2,3])
    end

    context "element with correct key" do
      it do
        Erledis.del("hello")
        expect(Erledis.exists?("hello")) |> to(be_false())
        expect(Erledis.get("hello")) |> to(eq nil)
      end
      it do
        Erledis.del("list")
        expect(Erledis.exists?("list")) |> to(be_false())
        expect(Erledis.get("list")) |> to(eq nil)
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.del(1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.del([1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.del("atom")) |> to(be_false())
      it do: expect(Erledis.del("string")) |> to(be_false())
    end
  end

  describe "exists?" do
    before do
      Erledis.set("hello", "word")
      Erledis.set("list", [1,2,3])
    end

    context "element with correct key" do
      it do: expect(Erledis.exists?("hello")) |> to(be_true())
      it do: expect(Erledis.exists?("list")) |> to(be_true())
    end

    context "element with incorrect key" do
      it do: expect(Erledis.exists?(1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.exists?([1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.exists?("atom")) |> to(be_false())
      it do: expect(Erledis.exists?("string")) |> to(be_false())
    end
  end

  describe "flushall" do
    before do
      Erledis.set("hello", "word")
      Erledis.set("list", [1,2,3])
    end

    context "should delete all elements" do
      it do
        Erledis.flushall()
        expect(Erledis.exists?("hello")) |> to(be_false())
        expect(Erledis.exists?("list")) |> to(be_false())
      end
    end
  end
end
