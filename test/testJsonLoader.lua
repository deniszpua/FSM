lunit = require("lunit")
jsonStateLoader = require("jsonStateLoader")

local M = {}

local function main()
	print(string.format("Load obj from string test: %s", M.testStringStructuer() and "O.K." or "Failed"))
end


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

main()
return M