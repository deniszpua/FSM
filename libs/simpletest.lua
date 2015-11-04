---------------------------------------------------
-- Simple lua test framework
-- @module simpletest
-------------------------------------------------
local M = {}
-- Import section
-- all module external dependencies are here

------------------------------------------------------------------
-- LAUNCHER (entry point)
------------------------------------------------------------------
local function main()
  -- check if module imported or called with arguments
  if #arg == 0 then return end
  -- display help, if needed 
  if arg[1] == '--help' or arg[1] == '-h' then
    print(string.format("Usage: %s [pathfile=<pathfile location>]" ..
      " <absolute path to testmodule> [secondTestmodule]", arg[0]))
    os.exit()
  end

  -- add project source folders to build path
  local projectBuildPath = ''
  if string.find(arg[1], 'pathfile=') then
    local fileName = string.gsub(arg[1], 'pathfile=', '')
    local file = io.open(fileName, 'r')
    if file then
      projectBuildPath = projectBuildPath .. file:read('*a')
      file:close()
    end
    -- remove first argument
    table.remove(arg, 1)
  end

  -- add test moudules location and possible source file location to build path
  local testModuleLocation, fileName = M.path.extractArgumentsLocation(arg[1])
  package.path = package.path or ""
  
  package.path = package.path .. ";" .. testModuleLocation .. "/?.lua;"
    .. projectBuildPath .. ";"

  -- forward test file names to test runner
  local testRunnerArguments = {}

  for i, path in ipairs(arg) do
    local dir, name = M.path.extractArgumentsLocation(path)
    testRunnerArguments[#testRunnerArguments + 1] = name
  end

  M.runner.run(testRunnerArguments, package.path)

end
--------------------------------------------------------------------
-- ASSERTIONS submodule
---------------------------------------------------------------------
M.assertions = {}
local assertions = M.assertions
----------------------------------------------------------------------
-- Tests whether expected match got or not.
--
-- Tables considered as equals if they have equals key-value pairs
-- @return               boolean result of test
--
function assertions.assertEquals(expected, got)
  if (type(got) ~= "table") then
    return (expected == got)
  else

    for k,v in pairs(got) do
      if (not assertions.assertEquals(expected[k], v)) then
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
function assertions.fail(msg)
  local message = msg or "Not implemented"
  error({["message"] = message})
end

---------------------------------------------------------------------------------------
-- Return true if tested function throws exception and false otherwise.
--
-- @param expression    expression to test
--
function assertions.assertThrowsException(expressionToTest)
  return  not pcall(function() expressionToTest() end)
end

-----------------------------------------------------------------------------------------
-- Returns true if got approximately equals expected
--
-- Returns true if abs(got - expected) <= delta and false otherwise
function assertions.assertApproximatelyEquals(expected, got, delta)
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
function assertions.assertStringMatchPattern(pattern, actualString)
  if (actualString:find(pattern)) then
    return true
  else
    return false
  end
end

--------------------------------------------------------------------------------
-- Checks whether got number greater than expected
--
function assertions.assertGreaterThanExpected(expected, got)
  return expected < got
end


--------------------------------------------------------------------------------
-- Checks whether got number less than expected
--
function assertions.assertLessThanExpected(expected, got)
  return expected > got
end


---------------------------------------------------------------------------------
-- PATH submodule
---------------------------------------------------------------------------------
-- Provide some functions for file path manipulation.
M.path = {}
local path = M.path


---------------------------------------------------------------------------
-- Separates filename from file's location
-- Operates properly on filenames, that have no dots in their names except one
-- separating fileanme from extension.
-- @param #string path path to file
-- @return #string path to directory, containing file and filename
--                without extention
function path.extractArgumentsLocation(path)

  -- adding folder path, if absent
  if not string.find(path, '(.*)/(.*)') then
    path = './' .. path
  end

  -- adding extension, if not present

  if not  string.find(path, '%.lua$') then
    path = path .. '.lua'
  end


  local location, filenameWithExtension, filename =
    string.match(path, '(.*)/(([^/]*).lua)')

  --  extract package name, if present
  local package, moduleName = string.match(filenameWithExtension, '(.*)[.]([^.]*).lua')
  if package then
    location = location .. '/' .. string.gsub(package, '[.]', '/')
    filename = moduleName
  end


  return location, filename
end

-----------------------------------------------------------------------
-- TEST-RUNNER submodule
-----------------------------------------------------------------------
-- This section provide main fasility for running unit test
-- on lua projects.
--
M.runner = {}
local runner = M.runner

-------
-- Runs all test methods in test modules.
-- Test suites to run should be specified as arguments to runner script.
-- All test methods should have test in their names.
-- @param #list arg list of test modules sources filenames.
--
function runner.run(arg, path)
  package.path = path
  local testRunner = runner.createTestRunner();
  for i = 1, #arg do
    local moduleUnderTest = require(arg[i])
    local testResult = testRunner:runTestSuite(moduleUnderTest)
    print(string.format("\nMoudle under test is %s:", arg[i]))
    for key, var in pairs(testResult) do
      print(string.format("%10s: %s", key, var))
    end
  end


end

----------------------------------------------------------
-- Test Object class factory
--
-- @param #function     methodUnderTest one of frameworks assertions
-- @return #table       testCase object
--
function runner.getTestObject (methodUnderTest)
  local obj = {method = methodUnderTest}
  obj.runTest = function (self)
    local status, result = pcall(function() return self.method() end)
    if status and result then return {status = "OK"}
    elseif status then return {status = "Failed"}
    else -- not status - test generated exception
      return {status = "Exception", errMessage = result}
    end
  end
  return obj
end

----------------------------------------------------------
-- Creates instance, that runs all tests in one module.
--
function runner.createTestRunner()
  local object = {}
  object.runTestSuite = function (self, moduleUnderTest)
    if not self and not moduleUnderTest then
      error("self and modulename not specified")
    end
    local testSuite = {}
    for key, testMethod in pairs(moduleUnderTest) do
      if string.match(key, "test") then
        testSuite[#testSuite + 1] = runner.getTestObject(testMethod)
      end
    end

    local testResult = {OK = 0, Failed = 0, Exception = 0}
    for i, test in ipairs(testSuite) do
      local res = test:runTest()
      testResult[res.status] = testResult[res.status] + 1
    end
    return testResult

  end
  return object
end

main()

return M
