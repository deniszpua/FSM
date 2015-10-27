------------------------------
--
-- @module jsonStateLoader
local M = {}

local json = require("dkjson")
local path = require("path")

local io = io
local assert = assert
local load = load
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

---
-- Creates object that represents entity, described by specified jsonString.
--
-- Uses dkjson library, that should be on project's build path.
-- @param #string jsonString valid json string representation of object
-- @return #table table, which structure was described by json and with specified keys
-- and values
function M.loadJsonData(jsonString)
  jsonString = string.lower(jsonString)
  local obj, pos, err = json.decode(jsonString)
  if err then
    error("Cannot parse json")
  else
    if obj.fsm ~= nil then obj = obj.fsm end
    return obj
  end

end


---
-- Loads string from file.
--
-- "~" sign in path is not supported (standart io library limitation).
function M.loadStringFromFile(pathToJsonFile)
  local file =  assert(io.open(pathToJsonFile, "r"))
  local str = file:read("*a")
  file:close()
  return str
end

---
-- Replaces conditions code with their predicate functions.
--
-- Condition should be specified
-- @return #table with conditional predicates instead of their code snippets
function M.recognizeConditions(fsm)

  local states = fsm.states

  if states then
    for _, state in pairs(states) do
      if state.junctions then
        for _, junction in pairs(state.junctions) do
          local conditionCode = load(junction.condition)
          if not conditionCode then
            error(string.format("Condition for state: %s not recognized", state.name))
          else
            junction.condition = conditionCode
          end

        end
      end
    end
  end

  return fsm

end


return M
