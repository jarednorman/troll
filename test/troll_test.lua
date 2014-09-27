test("troll", function()
  local foo
  before(function()
    foo = 3
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
