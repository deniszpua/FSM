local M = {}
-- import section
local Fsm = require("main.fsm")
local JsonHelper = require("main.jsonhelper")

local print = print
local io = io
local os = os
local arg = arg

if setfenv then
	setfenv(1, M) -- for 5.1
else
	_ENV = M -- for 5.2
end

function M.main()
  local sourceFileName = nil
  
  if arg then
    sourceFileName = arg[1] 
    if not sourceFileName then
    	sourceFileName = showSourceInputPromtAndRead()
    end
  else
    sourceFileName = showSourceInputPromtAndRead()
  end
  
  if not sourceFileName then
  	print("Cannot read initial state")
  	os.exit()
  end
  
  local fsm = Fsm.loadFSMFromJson(JsonHelper.loadStringFromFile(sourceFileName))
  print(fsm.getCurrentStateId())

    
end

function showSourceInputPromtAndRead()
	print('Input fsm state sourcefile name')
	return io.read()
end

--Run in IDE
main()

return M