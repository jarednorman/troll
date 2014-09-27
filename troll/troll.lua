local troll = {
  contexts = {},
  tests = {},
  current_context = nil
}

function troll:current_context()
  return self.contexts[#self.contexts] or self
end

function troll:push_context(name, fn)
  new_context = {
    name = name,
    fn = fn,
    contexts = {},
    tests = {},
    before_callbacks = {},
    results = {}
  }
  -- Add it to the tree.
  table.insert(self:current_context().contexts, new_context)
  -- Add it to the stack.
  table.insert(self.contexts, new_context)
  -- Run the "block".
  new_context.fn()
  -- Pop the context from the stack.
  table.remove(self.contexts)
end

function troll:push_test(name, fn)
  table.insert(self:current_context().tests, {name = name, fn = fn})
end

function troll:push_before(fn)
  table.insert(self:current_context().before_callbacks, fn)
end

local run_test = function(test)
  status, err = pcall(test)
  local result
  if status then
    result = false
  else
    result = err
  end
  return {
    name = test.name,
    result = result
  }
end

local run_context
run_context = function(context)
  -- run the tests
  for _, test in pairs(context.tests) do
    -- TODO: Run before blocks here
    table.insert(context.results, run_test(test))
  end

  -- run the contexts
  for _, context in pairs(context.contexts) do
    run_context(context)
  end
end

function troll:run_tests()
  run_context(self)
end

function troll:print_results()
  local depth = 0
  local increase_indent = function() depth = depth + 1 end
  local decrease_indent = function() depth = depth - 1 end
  local print_indented = function(str)
    print(string.rep("  ", depth) .. str)
  end

  local show_context_results
  show_context_results = function(context)
    print_indented(context.name)

    increase_indent()

    for _, test in pairs(context.results) do
      if test.result then
        print_indented("✗ " .. test.name)
        increase_indent()
        print_indented(test.result)
        decrease_indent()
      else
        print_indented("✓ " .. test.name)
      end
    end

    for _, context in pairs(context.contexts) do
      show_context_results(context)
    end

    decrease_indent()
  end

  for _, context in pairs(self.contexts) do
    show_context_results(context)
  end
end

return troll
