require 'test.helper'

test("troll.core", function()
  it("provides required functions when called", function()
    local run_tests, print_results, test, context, it, before = require 'troll.core'()
    assert(type(run_tests), "function")
    assert(type(print_tests), "function")
    assert(type(test), "function")
    assert(type(context), "function")
    assert(type(it), "function")
    assert(type(before), "function")
  end)

  it("secretly is maybe some aliases don't tell anyone", function()
    local run_tests, print_results, test, context, it, before = require 'troll.core'()
    assert(test == context)
  end)
end)
