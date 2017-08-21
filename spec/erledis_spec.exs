defmodule ErledisSpec do
  use ESpec

  describe "set" do
    before do: Erledis.start_link

    context "correct key" do
      it "with single element" do
        Erledis.set("set_1", {1,2,3})
        expect(Erledis.exists?("set_1")) |> to(be_true())
        expect(Erledis.get("set_1")) |> to(eq [{1,2,3}])
      end

      it "with multiple elements" do
        Erledis.set("set_2", "word")
        expect(Erledis.exists?("set_2")) |> to(be_true())
        expect(Erledis.get("set_2")) |> to(eq ["word"])
        Erledis.set("set_2", [1,2,3])
        expect(Erledis.get("set_2")) |> to(eq ["word", [1,2,3]])
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.set(1, 2)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.set([1], 2)) |> to(eq "key argument must be a string")
    end
  end

  describe "get" do
    before do: Erledis.start_link

    context "value by key" do
      before do
        Erledis.set("get_1", "word")
        Erledis.set("get_1", {1,2,3})
        Erledis.set("get_2", [1,2,3])
      end

      it do
        expect(Erledis.get("get_1")) |> to(eq ["word", {1,2,3}])
        expect(Erledis.get("get_2")) |> to(eq [[1,2,3]])
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.get(1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.get([1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.get("atom")) |> to(eq [])
      it do: expect(Erledis.get("string")) |> to(eq [])
    end
  end

  describe "push" do
    before do: Erledis.start_link

    context "with correct key" do
      context "where key is defined" do
        before do
          Erledis.set("push", "word")
        end

        it do
          expect(Erledis.push("push", 10)) |> to(eq [10, "word"])
          expect(Erledis.push("push", {1,2,3})) |> to(eq [{1,2,3}, 10, "word"])
        end
      end

      context "where key is undefined" do
        it do: expect(Erledis.push("atom", :atom)) |> to(eq [:atom])
        it do: expect(Erledis.push("tuple", {1,2,3})) |> to(eq [{1,2,3}])
      end
    end

    context "with incorrect key" do
      it do: expect(Erledis.push(1, 2)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.push([1], 2)) |> to(eq "key argument must be a string")
    end
  end

  describe "pop" do
    before do: Erledis.start_link

    context "with correct key" do
      context "where key is defined" do
        before do
          Erledis.set("pop", "word")
          Erledis.set("pop", [1,2,3])
          Erledis.set("pop", {1,2,3})
        end

        it do
          expect(Erledis.pop("pop")) |> to(eq {1,2,3})
          expect(Erledis.get("pop")) |> to(eq ["word", [1,2,3]])
          expect(Erledis.pop("pop")) |> to(eq [1,2,3])
          expect(Erledis.get("pop")) |> to(eq ["word"])
        end
      end

      context "where key is undefined" do
        it do: expect(Erledis.pop("atom")) |> to(eq nil)
        it do: expect(Erledis.pop("tuple")) |> to(eq nil)
      end
    end

    context "with incorrect key" do
      it do: expect(Erledis.pop(1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.pop([1])) |> to(eq "key argument must be a string")
    end
  end

  describe "delete" do
    before do: Erledis.start_link

    context "element with correct key" do
      before do
        Erledis.set("hello", "word")
        Erledis.set("list", [1,2,3])
      end

      it do
        Erledis.del("hello")
        expect(Erledis.exists?("hello")) |> to(be_false())
        expect(Erledis.get("hello")) |> to(eq [])
      end

      it do
        Erledis.del("list")
        expect(Erledis.exists?("list")) |> to(be_false())
        expect(Erledis.get("list")) |> to(eq [])
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
    before do: Erledis.start_link

    context "element with correct key" do
      before do
        Erledis.set("hello", "word")
        Erledis.set("list", [1,2,3])
      end

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
      Erledis.start_link
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
