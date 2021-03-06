return function()
  local troll = {
    stack = {},
    contexts = {},
    tests = {},
    before_hooks = {},
    after_hooks = {},
    current_context = nil
  }

  function troll:current_context()
    return self.stack[#self.stack] or self
  end

  function troll:push_context(name, fn)
    new_context = {
      parent = self:current_context(),
      name = name,
      fn = fn,
      contexts = {},
      tests = {},
      before_hooks = {},
      after_hooks = {},
      results = {}
    }

    -- Add it to the tree.
      table.insert(self:current_context().contexts, new_context)
    -- Add it to the stack.
    table.insert(self.stack, new_context)
    -- Run the "block".
    new_context.fn()
    -- Pop the context from the stack.
    table.remove(self.stack)
  end

  function troll:push_test(name, fn)
    table.insert(self:current_context().tests, {name = name, fn = fn})
  end

  function troll:push_before(fn)
    table.insert(self:current_context().before_hooks, fn)
  end

  function troll:push_after(fn)
    table.insert(self:current_context().after_hooks, fn)
  end

  local run_test = function(test)
    local traceback = false
    local failure = false

    xpcall(test.fn, function(err)
      traceback = debug.traceback()
      failure = err
    end)

    return {
      name = test.name,
      failure = failure,
      traceback = traceback
    }
  end

  local run_before_hooks
  run_before_hooks = function(context)
    if context then
      run_before_hooks(context.parent)
      for _, hook in pairs(context.before_hooks) do
        hook()
      end
    end
  end

  local run_after_hooks
  run_after_hooks = function(context)
    if context then
      run_after_hooks(context.parent)
      for _, hook in pairs(context.after_hooks) do
        hook()
      end
    end
  end

  local run_context
  run_context = function(context)
    -- run the tests
    for _, test in pairs(context.tests) do
      run_before_hooks(context)
      table.insert(context.results, run_test(test))
      run_after_hooks(context)
    end

    -- run the contexts
    for _, context in pairs(context.contexts) do
      run_context(context)
    end
  end

  function troll:run_tests()
    run_context(self)
  end

  local full_context_label
  full_context_label = function(context)
    if context.parent then
      return full_context_label(context.parent) .. context.name .. " "
    else
      return ""
    end
  end

  local colourizer = function(code)
    return function(fn)
      io.write(code)
      fn()
      io.write "\27[0m"
    end
  end

  local red = colourizer "\27[31m"
  local green = colourizer "\27[32m"
  local yellow = colourizer "\27[33m"

  function troll:print_results()
    print "Results:\n"

    local depth = -1
    local increase_indent = function() depth = depth + 1 end
    local decrease_indent = function() depth = depth - 1 end
    local print_indented = function(str)
      print(string.rep("  ", depth) .. str)
    end

    local show_context_results
    show_context_results = function(context)
      if context.name then
        print_indented(context.name)
      end

      increase_indent()

      if context.results then
        for _, test in pairs(context.results) do
          if test.failure then
            red(function()
              print_indented("✗ " .. test.name)
            end)
          else
            green(function()
              print_indented("✓ " .. test.name)
            end)
          end
        end
      end

      for _, context in pairs(context.contexts) do
        show_context_results(context)
      end

      decrease_indent()
    end
    show_context_results(self)

    print "\nFailures:"

    local show_context_tracebacks
    show_context_tracebacks = function(context)
      if context.results then
        for _, test in pairs(context.results) do
          if test.failure then
            print("")
            red(function()
              print(full_context_label(context) .. test.name)
            end)
            yellow(function()
              print(test.failure)
              print(test.traceback)
            end)
          end
        end
      end

      for _, context in pairs(context.contexts) do
        show_context_tracebacks(context)
      end
    end

    show_context_tracebacks(self)
  end

  return troll
end
