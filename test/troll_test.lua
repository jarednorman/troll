require 'test.helper'

test("troll.troll", function()
  local troll

  before(function()
    -- Reload troll
    troll = require 'troll.troll'()
  end)

  describe(":current_context()", function()
    when("the stack is not empty", function()
      it("returns the top of the stack", function()
        local fake_context = {}
        table.insert(troll.stack, fake_context)
        assert(troll:current_context() == fake_context)
      end)
    end)

    when("the stack is empty", function()
      it("returns troll itself", function()
        print('yolo')
        print(#troll.stack)
        assert(troll:current_context() == troll)
      end)
    end)
  end)

  describe(":push_test()", function()
    local test_name = "foo_bar"
    local test_fn = function() end

    it("adds a test table to the current context's tests", function()
      troll:push_test(test_name, test_fn)

      local current_tests = troll:current_context().tests

      assert(current_tests[#current_tests].name == test_name)
      assert(current_tests[#current_tests].fn == test_fn)
    end)
  end)

  describe(":push_after()", function()
    local after_fn = function() end

    it("adds the function to the contexts after hooks", function()
      troll:push_after(after_fn)

      local current_after_hooks = troll:current_context().after_hooks

      assert(current_after_hooks[#current_after_hooks] == after_fn)
    end)
  end)

  describe(":push_before()", function()
    local before_fn = function() end

    it("adds the function to the contexts before hooks", function()
      troll:push_before(before_fn)

      local current_before_hooks = troll:current_context().before_hooks

      assert(current_before_hooks[#current_before_hooks] == before_fn)
    end)
  end)
end)
