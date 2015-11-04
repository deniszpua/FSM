-------------------------------------------------------------
-- Module, that represents finite state machine
--
-- @module fsm
------------------------------------------------------------
local M = {}

local State = require("state")
local Junction = require("junction")

local json = require("dkjson")

local path = require("path")

local io = io
local assert = assert
local load = load
local print = print
local pairs = pairs
local ipairs = ipairs
local error = error
local string = string
local type = type
local setmetatable = setmetatable

if setfenv then
  setfenv(1, M) -- for 5.1
else
  _ENV = M -- for 5.2
end
--------------------------------------------------------------------
-- Returns new FSM instance.
-- @callof #fsm module
--
function M.createFSM()

  -- private methods and variables
  local self = {
    states = {}
  }

  -- public methods and variables access object
  local fsm_public = {
    keys = {},
  }

  ------------------------------------------------------------------------------
  -- Adds new state to current final state machine.
  --
  -- If current fsm instance has no states, than it automatically transitions to
  -- newly created state.
  --
  -- @param #string name_id name of state, that will be created.
  function fsm_public.addState(name_id)

    local state = State.createState(name_id, fsm_public)
    self.states[name_id] = state

    if not self.currentState then
      self.currentState = state
      state.enter()
    end

    return state
  end


  --------------------------------------------------------------------------------
  -- Adds new junction between states.
  --
  -- @param #string state_id1 name of state, in which condition will be checked.
  -- @param #string state_id2 name of state, to which fsm will transition when  condition becomes true.
  -- @param #function condition predicate, which will be checked to become true.
  function fsm_public.addJunction(state_id1, state_id2, condition)

    if not condition then
      return Junction(state_id1, state_id2, fsm_public)
    end

    local state = self.states[state_id1]
    state.addJunction(condition, state_id2)

  end

  -------------------------------------------------------------
  -- fsm key setter.
  function fsm_public.setKey(keyId, newValue)
    fsm_public.keys[keyId] = newValue
    self.currentState.processJunctions()
  end



  ---------------------------------------------------------------
  -- Updates fsm state (calls current state onUpdate handlers)
  -- and starts verifying junctions chain.
  --
  function fsm_public.update()
    self.currentState.update()
    self.currentState.processJunctions()
  end

  -------------------------------------------------------------
  -- Transitions fsm to new state
  --
  function fsm_public.setNewState(state_id)
    self.currentState.exit()
    self.currentState = self.states[state_id]
    self.currentState.enter()
  end

  --------------------------------------------------------------
  -- Current state id getter.
  --
  function fsm_public.getCurrentStateId ()
    return self.currentState.getName()
  end




  return fsm_public
end

setmetatable(M, {__call = M.createFSM})

----------------------------------------------------------------
-- Initialization from JSON helper functions
-----------------------------------------------------------------
--
--

---
-- Creates object that represents entity, described by specified jsonString.
--
-- Uses dkjson library, that should be present on project's build path.
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
          local conditionCode = load("return " .. junction.condition)
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


function M.recognizeHandlers(fsm)
  if fsm.states then
    for _, state in ipairs(fsm.states) do
      if state.handlers then
        for _, handler in pairs(state.handlers) do
          local action = load(handler.action)
          if action then
            handler.action = action
          else
            error(string.format("%s handler for state % is not recognized",
              handler.event, state.name))
          end
        end
      end
    end
  end
  return fsm
end

return M
