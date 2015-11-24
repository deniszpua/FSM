local M = {}
-- import section
local Fsm = require("main.fsm")
local JsonHelper = require("main.jsonhelper")

local print = print
local io = io
local os = os
local arg = arg
local string = string
local tonumber = tonumber

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
  fsm.update()

  local input = nil
  
  while input ~= 'exit' do
    input = io.read()
    if input then
      for kvPair in string.gmatch(input, "[^:]+:[^:]+") do
        local key = string.match(kvPair, "^%a+")
        local value = parseValue(kvPair)
        fsm.setKey(key, value)
      end
      fsm.update()
    end
  	
  end


end


---------------------------------------
-- PRIVATE FUNCTIONS
--------------------------------------

-- Shows prompt and reads input
function showSourceInputPromtAndRead()
  print('Input fsm state sourcefile name')
  return io.read()
end

-- Extracts argument value from string representation of key:value pair and
-- converts it (if possible) to number or boolean value. Strings  'nil', 'false', 'False',
-- 'FALSE' converted to false, 'true', 'True', 'TRUE' treated as true, numbers converted to numbers and
-- other values returned as strings.
function parseValue(kvPairString)
  local value = string.match(kvPairString, "[^:]+$")
  
  if string.lower(value) == 'false' or string.lower(value) == 'nil' then
    return false
  elseif string.lower(value) == 'true' then
    return true
  else
    if tonumber(value) then
      return tonumber(value)
    end
  end
  
  return value
end

--Run in IDE
main()

return M
