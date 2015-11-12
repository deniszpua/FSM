-------------------------------------------------------------
-- Module, that represents finite state machine
--
-- @module fsm
------------------------------------------------------------
local M = {}

local State = require("main.state")
local Junction = require("main.junction")

local JsonHelper = require("main.jsonhelper")

local path = require("common.path")

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
-- Returns new empty FSM instance.
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

  ---
  -- Changes current state to current without triggering any event
  --
  function fsm_public.rawSetCurrentState(targetStateId)
    if self.states[targetStateId] then
      local targetStateInstance = self.states[targetStateId] 
      self.currentState = targetStateInstance
    else
      error(string.format("State %s is not valid state name", targetStateId))
    end
  end



  return fsm_public
end

------------------------------------------------------------------
-- Returns fsm instance with state, described by given jsonString
-- @param #string jsonString valid json string that match following pattern
--    {"FSM": {"States":[{"Name":"state1Name", "junctions":[{"condition":"false', "state":"targetState"}, ...],
--      "handlers":{{"event":"onEnter", "action":"..."}, ... }},
--     {"name":"targetState"}], "StartState":"init"}}
function M.loadFSMFromJson(jsonString)
  local jsonTemplate = JsonHelper.loadJsonData(jsonString)

  if jsonTemplate then
    jsonTemplate = JsonHelper.recognizeConditions(jsonTemplate)
    jsonTemplate = JsonHelper.recognizeHandlers(jsonTemplate)
  end

  local fsmInstance = M.createFSM()
  if jsonTemplate then
    for _, state in pairs(jsonTemplate.states) do
      local newState = fsmInstance.addState(state.name)
      if state.junctions then
        for _, junction in pairs(state.junctions) do
          newState.addJunction(junction.condition, junction.state)
        end
      end
      if state.handlers then
        for _, handler in pairs(state.handlers) do
          newState.addHandler(handler.event, handler.action)
        end
      end
    end
  end

  if jsonTemplate.startState then
    fsmInstance.rawSetCurrentState(jsonTemplate.startState)
  end

  return fsmInstance

end


setmetatable(M, {__call = M.createFSM})

return M
