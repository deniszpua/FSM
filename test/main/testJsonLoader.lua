local Assertions = require("testing.assertions")
local jsonStateLoader = require("main.jsonhelper")

local M = {}


--- It should create object with structure, specified in json string
function M.testStringStructure()

  local testString = 
  [[{"fsm": {
      "states":[{"name":"init"}, {"name":"zombie"}, {"name":"running"}],
      "startState":"init"
    }}
  ]]
	local resultObj = jsonStateLoader.loadJsonData(testString)
	return Assertions.assertEquals(true, #resultObj.states == 3 and resultObj.startState == "init")
end

--- It should recognize conditions, that stored in json fields
function M.testRecognizeConditions()

  local fsm = {
          states={
                {name = "state 1", junctions = {{condition = "return true", state = "state 2"}}},
                {name = "state 2"}
                }
              }
  
	return Assertions.assertEquals(true,(jsonStateLoader.recognizeConditions(fsm)).states[1].junctions[1].condition())
	
end

-- It should recognize handlers correctly
function M.testRecognizeHandlers()
  local handlermock = {actionPerformed = false}
  local frankenstein = {
          states={
                {name = "state 1", junctions = {{condition = "true", state = "state 2"}}},
                {name = "state 2", handlers={{event="onEnter", action = "function(keys) keys.actionPerformed = true"}}}
                }
              }
  frankenstein = jsonStateLoader.recognizeHandlers(frankenstein) 
  frankenstein.states[2].handlers[1].action(handlermock)           
	return Assertions.assertEquals(true,handlermock.actionPerformed)
end




return M