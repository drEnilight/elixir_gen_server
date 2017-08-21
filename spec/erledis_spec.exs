defmodule ErledisSpec do
  use ESpec

  describe "set" do
    let server_name: "set"

    before do: Erledis.start_link(server_name())

    context "correct key" do
      it "with single element" do
        Erledis.set(server_name(), "set_1", {1,2,3})
        expect(Erledis.exists?(server_name(), "set_1")) |> to(be_true())
        expect(Erledis.get(server_name(), "set_1")) |> to(eq [{1,2,3}])
      end

      it "with multiple elements" do
        Erledis.set(server_name(), "set_2", "word")
        expect(Erledis.exists?(server_name(), "set_2")) |> to(be_true())
        expect(Erledis.get(server_name(), "set_2")) |> to(eq ["word"])
        Erledis.set(server_name(), "set_2", [1,2,3])
        expect(Erledis.get(server_name(), "set_2")) |> to(eq ["word", [1,2,3]])
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.set(server_name(), 1, 2)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.set(server_name(), [1], 2)) |> to(eq "key argument must be a string")
    end
  end

  describe "get" do
    let server_name: "get"

    before do: Erledis.start_link(server_name())

    context "value by key" do
      before do
        Erledis.set(server_name(), "get_1", "word")
        Erledis.set(server_name(), "get_1", {1,2,3})
        Erledis.set(server_name(), "get_2", [1,2,3])
      end

      it do
        expect(Erledis.get(server_name(), "get_1")) |> to(eq ["word", {1,2,3}])
        expect(Erledis.get(server_name(), "get_2")) |> to(eq [[1,2,3]])
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.get(server_name(), 1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.get(server_name(), [1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.get(server_name(), "atom")) |> to(eq [])
      it do: expect(Erledis.get(server_name(), "string")) |> to(eq [])
    end
  end

  describe "push" do
    let server_name: "push"

    before do: Erledis.start_link(server_name())

    context "with correct key" do
      context "where key is defined" do
        before do
          Erledis.set(server_name(), "push", "word")
        end

        it do
          expect(Erledis.push(server_name(), "push", 10)) |> to(eq [10, "word"])
          expect(Erledis.push(server_name(), "push", {1,2,3})) |> to(eq [{1,2,3}, 10, "word"])
        end
      end

      context "where key is undefined" do
        it do: expect(Erledis.push(server_name(), "atom", :atom)) |> to(eq [:atom])
        it do: expect(Erledis.push(server_name(), "tuple", {1,2,3})) |> to(eq [{1,2,3}])
      end
    end

    context "with incorrect key" do
      it do: expect(Erledis.push(server_name(), 1, 2)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.push(server_name(), [1], 2)) |> to(eq "key argument must be a string")
    end
  end

  describe "pop" do
    let server_name: "pop"

    before do: Erledis.start_link(server_name())

    context "with correct key" do
      context "where key is defined" do
        before do
          Erledis.set(server_name(), "pop", "word")
          Erledis.set(server_name(), "pop", [1,2,3])
          Erledis.set(server_name(), "pop", {1,2,3})
        end

        it do
          expect(Erledis.pop(server_name(), "pop")) |> to(eq {1,2,3})
          expect(Erledis.get(server_name(), "pop")) |> to(eq ["word", [1,2,3]])
          expect(Erledis.pop(server_name(), "pop")) |> to(eq [1,2,3])
          expect(Erledis.get(server_name(), "pop")) |> to(eq ["word"])
        end
      end

      context "where key is undefined" do
        it do: expect(Erledis.pop(server_name(), "atom")) |> to(eq nil)
        it do: expect(Erledis.pop(server_name(), "tuple")) |> to(eq nil)
      end
    end

    context "with incorrect key" do
      it do: expect(Erledis.pop(server_name(), 1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.pop(server_name(), [1])) |> to(eq "key argument must be a string")
    end
  end

  describe "delete" do
    let server_name: "delete"

    before do: Erledis.start_link(server_name())

    context "element with correct key" do
      before do
        Erledis.set(server_name(), "hello", "word")
        Erledis.set(server_name(), "list", [1,2,3])
      end

      it do
        Erledis.del(server_name(), "hello")
        expect(Erledis.exists?(server_name(), "hello")) |> to(be_false())
        expect(Erledis.get(server_name(), "hello")) |> to(eq [])
      end

      it do
        Erledis.del(server_name(), "list")
        expect(Erledis.exists?(server_name(), "list")) |> to(be_false())
        expect(Erledis.get(server_name(), "list")) |> to(eq [])
      end
    end

    context "element with incorrect key" do
      it do: expect(Erledis.del(server_name(), 1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.del(server_name(), [1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.del(server_name(), "atom")) |> to(be_false())
      it do: expect(Erledis.del(server_name(), "string")) |> to(be_false())
    end
  end

  describe "exists?" do
    let server_name: "exists"

    before do: Erledis.start_link(server_name())

    context "element with correct key" do
      before do
        Erledis.set(server_name(), "hello", "word")
        Erledis.set(server_name(), "list", [1,2,3])
      end

      it do: expect(Erledis.exists?(server_name(), "hello")) |> to(be_true())
      it do: expect(Erledis.exists?(server_name(), "list")) |> to(be_true())
    end

    context "element with incorrect key" do
      it do: expect(Erledis.exists?(server_name(), 1)) |> to(eq "key argument must be a string")
      it do: expect(Erledis.exists?(server_name(), [1])) |> to(eq "key argument must be a string")
    end

    context "undefined element" do
      it do: expect(Erledis.exists?(server_name(), "atom")) |> to(be_false())
      it do: expect(Erledis.exists?(server_name(), "string")) |> to(be_false())
    end
  end

  describe "flushall" do
    let server_name: "flushall"

    before do
      Erledis.start_link(server_name())
      Erledis.set(server_name(), "hello", "word")
      Erledis.set(server_name(), "list", [1,2,3])
    end

    context "should delete all elements" do
      it do
        Erledis.flushall(server_name())
        expect(Erledis.exists?(server_name(), "hello")) |> to(be_false())
        expect(Erledis.exists?(server_name(), "list")) |> to(be_false())
      end
    end
  end
end
