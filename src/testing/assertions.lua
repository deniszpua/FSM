--------------------------------------------------------------------
-- Bunch of assertions for using with simpletest framework.
-- @module assertions
---------------------------------------------------------------------
M = {}
----------------------------------------------------------------------
-- Tests whether expected match got or not.
--
-- Tables considered as equals if they have equals key-value pairs
-- @return               boolean result of test
--
function M.assertEquals(expected, got)
  if (type(got) ~= "table") then
    return (expected == got)
  else

    for k,v in pairs(got) do
      if (not M.assertEquals(expected[k], v)) then
        return false
      end
    end
    return true
  end
end

------------------------------------------------------------------------------------------
-- Always fails.
--
-- Raises and exception with messaged passed as argument or "not implemented"
-- in case of message absence.
--
-- @param msg           [optional] message to be passed as exception
--
function M.fail(msg)
  local message = msg or "Not implemented"
  error({["message"] = message})
end

---------------------------------------------------------------------------------------
-- Return true if tested function throws exception and false otherwise.
--
-- @param expression    expression to test
--
function M.assertThrowsException(expressionToTest)
  return  not pcall(function() expressionToTest() end)
end

-----------------------------------------------------------------------------------------
-- Returns true if got approximately equals expected
--
-- Returns true if abs(got - expected) <= delta and false otherwise
function M.assertApproximatelyEquals(expected, got, delta)
  local actualDelta = expected - got
  if actualDelta < 0 then
    actualDelta = actualDelta * -1
  end
  return actualDelta <= delta
end


-----------------------------------------------------------------------------
-- Checks whether got string match expected pattern
--
--
function M.assertStringMatchPattern(pattern, actualString)
  if (actualString:find(pattern)) then
    return true
  else
    return false
  end
end

--------------------------------------------------------------------------------
-- Checks whether got number greater than expected
--
function M.assertGreaterThanExpected(expected, got)
  return expected < got
end


--------------------------------------------------------------------------------
-- Checks whether got number less than expected
--
function M.assertLessThanExpected(expected, got)
  return expected > got
end

return M
