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

function troll:print_results()
end

local run_test = function(test)
  status, err = pcall(test)
  if status then
    local result = false
  else
    local result = err
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

return troll
