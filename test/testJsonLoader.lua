lunit = require("lunit")
jsonStateLoader = require("jsonStateLoader")

local M = {}

local function main()
	print(string.format("Load obj from string test:\t%s", M.testStringStructuer() and "O.K." or "Failed"))
	print(string.format("Recognize conditions test:\t%s", M.testRecognizeConditions() and "O.K." or "Failed"))
end

--- It should create object with structure, specified in json string
function M.testStringStructuer()

  local testString = 
  [[{"FSM": {
      "States":[{"Name":"init"}, {"name":"zombie"}, {"name":"running"}],
      "StartState":"init"
    }}
  ]]
	local resultObj = jsonStateLoader.loadJsonData(testString)
	return lunit.assertEquals(true, #resultObj.states == 3 and resultObj.startstate == "init")
end

--- It should recognize conditions, that stored in json fields
function M.testRecognizeConditions()

  local fsm = {
          states={
                {name = "state 1", junctions = {{condition = "true", state = "state 2"}}},
                {name = "state 2"}
                }
              }
  
	return lunit.assertEquals(true,(jsonStateLoader.recognizeConditions(fsm)).states[1].junctions[1].condition())
	
end



main()
return M