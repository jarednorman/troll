local troll = require 'troll.troll'

local run_tests = function()
  troll:run_tests()
end

local print_results = function()
  troll:print_results()
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

-- Require cannot return multiple values.
return function()
  return run_tests, print_results, test, context, it, before
end
