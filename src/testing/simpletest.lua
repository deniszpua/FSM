---------------------------------------------------
-- Simple lua test framework
-- @module simpletest
-------------------------------------------------
local M = {}
-- Import section
-- all module external dependencies are here

local path = require("common.path")

------------------------------------------------------------------
-- LAUNCHER (entry point)
------------------------------------------------------------------
-- Runs all tests in given test modules, and prints results.
-- 
-- @param #string arg [pathfile=filename] firstTestModule [secondTestmodule] ...
function M.main(arg)
  
  -- convert string to list
  local parser = {}
  for argument in string.gmatch(arg, '[^ ]+%s*') do
    -- deleting trailing spaces
    if string.find(argument, '%s') then argument = string.gsub(argument, '%s', '') end
    parser[#parser + 1] = argument
  end
  arg = parser

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
  local testModuleLocation, fileName = path.extractArgumentsLocation(arg[1])
  package.path = package.path or ""
  
  package.path = package.path .. ";" .. testModuleLocation .. "/?.lua;"
    .. projectBuildPath .. ";"

  -- forward test file names to test runner
  local testRunnerArguments = {}

  for i, filename in ipairs(arg) do
    local dir, name = path.extractArgumentsLocation(filename)
    testRunnerArguments[#testRunnerArguments + 1] = name
  end

  M.runner.run(testRunnerArguments, package.path)
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
    for _, key in pairs({"OK", "Failed", "Exception"}) do
      print(string.format("%10s: %s", key, testResult[key]))
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

--Run in IDE
local testSuitesToRun = ''
      .. 'main.test-fsm.lua '
      .. 'main.test-state.lua '
      .. 'main.testJsonLoader.lua'
M.main('pathfile=/Users/denis/workspace/lua_tutorial/FSM/buildpath '
      .. testSuitesToRun)

return M
