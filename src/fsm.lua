-------------------------------------------------------------
-- Module, that represents finite state machine
--
-- @module fsm
------------------------------------------------------------
local M = {}

local State = require("state")
local Junction = require("junction")


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

return M
