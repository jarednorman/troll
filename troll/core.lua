local test = function(subject, fn)
  fn()
end

local it = function(name, fn)
  fn()
end

local before = function(fn)
end

-- Require cannot return multiple values.
return function()
  return test, it, before
end
