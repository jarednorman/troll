test("troll", function()
  local foo
  local array_of_things

  context("contexts", function()
    before(function()
      table.insert(array_of_things, "outer context")
    end)

    it("call the before blocks for contexts in the right order", function()
      assert(unpack(array_of_things) == "outer context")
    end)

    context("nested contexts", function()
      before(function()
        table.insert(array_of_things, "inner context")
      end)

      it("call the before blocks for nested contexts in the right order", function()
        assert(unpack(array_of_things) == "outer context", "inner context")
      end)
    end)
  end)

  before(function()
    foo = 3
    array_of_things = {}
  end)

  it("runs tests", function()
    assert(foo == 3)
  end)

  it("fails tests", function()
    assert(foo == 4)
  end)

  it("loads the test helper", function()
    assert(test_helper_loaded)
  end)
end)
