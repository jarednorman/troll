local test = function(subject, fn)
  print(subject)
  fn()
end

local it = function(name, fn)
  status, err = pcall(fn)
  if status then
    print("  " .. name .. " (PASSED)")
  else
    print("  " .. name .. " (FAILED)")
    print("    " .. err)
  end
end

local before = function(fn)
  fn()
end

-- Require cannot return multiple values.
return function()
  return test, it, before
end
