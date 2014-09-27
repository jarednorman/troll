local troll = {
  contexts = {},
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
    before_callbacks = {}
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
end

function troll:push_before(fn)
  table.insert(self:current_context().before_callbacks, fn)
end

function troll:run_tests()
end

local test = function(name, fn)
  troll:push_context(name, fn)
end
local context = test

local it = function(name, fn)
  troll:push_test(name, fn)
end

local before = function(fn)
  troll:push_before(fn)
end

local run_tests = function()
  troll:run_tests()
end

-- Require cannot return multiple values.
return function()
  return run_tests, test, context, it, before
end
