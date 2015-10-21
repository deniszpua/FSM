-------------------------------------------------------------
-- Module, that represents finite state machine
--
-- @module fsm
------------------------------------------------------------
local M = {}

local print = print
local state_module = require("state")
local junction_module = require("junction")

_ENV = M

--------------------------------------------------------------------
-- Returns new FSM instance.
--
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
  fsm_public.addState = function (name_id)

    local state = state_module.State.createState(name_id, fsm_public)
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
  fsm_public.addJunction = function (state_id1, state_id2, condition)

    if not condition then return junction_module.Junction.createJunction(state_id1, state_id2, fsm_public) end

    local state = self.states[state_id1]
    state.addJunction(condition, state_id2)

  end
  
  -------------------------------------------------------------
  -- fsm key setter.
  fsm_public.setKey = function (keyId, newValue)
    fsm_public.keys[keyId] = newValue
    self.currentState.processJunctions()
  end
  
  
  
  ---------------------------------------------------------------
  -- Updates fsm state (calls current state onUpdate handlers)
  -- and starts verifying junctions chain.
  -- 
  fsm_public.update = function ()
  	self.currentState.update()
  	self.currentState.processJunctions()
  end
  
  -------------------------------------------------------------
  -- Transitions fsm to new state
  -- 
  fsm_public.setNewState = function (state_id)
    self.currentState.exit()
  	self.currentState = self.states[state_id]
  	self.currentState.enter()
  end
  
  
  return fsm_public
end

------------------------------------------
-- Unit test
------------------------------------------
local function main()

  --

  local fsm = M.createFSM();
  local state1 = fsm.addState("initial State")

  state1.addHandler("onEnter", function() print("Init state onEnter handler") end)
  state1.addHandler("onExit", function() print("Init state onExit handler") end)
  state1.addHandler("onUpdate", function() print("Init state onUpdate handler") end)


  local state2 = fsm.addState("state2");

  state2.addHandler("onEnter", function () print("state2 onEnter handler")end)

  local junction = junction_module.Junction.createJunction(state1.getName(), state2.getName(), fsm)
  junction.setCondition(function(state1, keys) return keys.my_var == 1 end)
  
  fsm.setKey("my_var", 1)


  --[[
  
      addState(name_id)
      local state = fsm.addState(“my_state”)
      
      
      state.addEventHandler(onEnter, function () print (“enter”) end)
      onEnter / onExit / onUpdate
      
      
      local junction = fsm.addJunction (“my_state1”, “my_state2”)
      junction.setCondition(function (state, keys) return keys.my_var == 1 end)
      
      fsm.setKey(“my_var”, 1)
      fsm.update()
      fsm.addJunction (“my_state1”, “my_state2”, callback)
      fsm.addJunction(state1, state2, callback)
        
  
  
  --]]

end

main()

return M
