------------------------------
--
-- @module jsonStateLoader
local M = {}

local json = require("dkjson")
local path = require("path")

local io = io 
local assert = assert
local print = print
local pairs = pairs
local error = error
local string = string
local type = type

if setfenv then
  setfenv(1, M) -- for 5.1
else
  _ENV = M -- for 5.2
end

--- Helper function for debugging
local function objToString(obj)
  local result = "{"
  for k, v in pairs(obj) do
    if type(v) ~= "table" then
      result = result .. string.format("%s : %s, ", k, v)
    else
      result = result .. string.format("%s: %s, ", k, objToString(v))
    end
  end
  result = result .. "}"
  return result

end

function main()
  -- sample string for unit test
  local jsonString =
    [[{"FSM":
    {"Name":"cvetok5_zone_controller", 
      "States":[
        {"Name":"idle", 
          "Junctions": [
            {"Condition":"event.cvetok5_zone_touched and not GetSprite('cvetok5').is_active",
            "State":"cvetok5"
              },
            {"Condition":"event.cvetok5_zone_touched and GetSprite('cvetok5').is_active",
            "State":"cvetok5_1"
              }
            ]
          },
        {"Name":"cvetok5",
          "Animation":"p1_cvetok5_1",
          "NextState":"idle",
          "OnEnter":"PlaySound('p1_cvetok5_1')DeactivateSprites('jagoda5')",
          "OnExit":"ActivateSprites('cvetok5', 'list5_1', 'list5_2')"
          },
        {"Name":"cvetok5_1",
          "Animation":"p1_cvetok5_2",
          "NextState":"idle",
          "OnEnter":"PlaySound('p1_cvetok5_2')DeactivateSprites('cvetok5', 'list5_1', 'list5_2')",
          "OnExit":"ActivateSprites('jagoda5')"
          }
        ],
      "StartState":"idle"
      }
  }]]

    local loadedObject = M.loadJsonData(M.loadStringFromFile('/home/dev-user/Desktop/sample.json'))
    print(objToString(loadedObject))

end


function M.loadJsonData(jsonString)
  local obj, pos, err = json.decode(jsonString)
  if err then
    error("Cannot parse json")
  else
    return obj
  end

end

function M.loadStringFromFile(pathToJsonFile)
	local file =  assert(io.open(pathToJsonFile, "r"))
	local str = file:read("*a")
	file:close()
	return str
end



main()

return M
