-------------------------------------------------------------
-- Module, that represents finite state machine
--
-- @module fsm
------------------------------------------------------------
local M = {}

local print = print
local assert = assert
local type = type
local string_format = string.format
local ipairs = ipairs
local setmetatable = setmetatable

--_ENV = M

---------------------------------------------------------------------
-- FSM state class
--
--
M.State = {

    -------------------------------------------------------------------------------------------------
    -- State objects factory method.
    --
    createState = function (state_name, enclosingFsmReference)

      -- private instance variables container
      local self = {
        name = state_name,
        fsm = enclosingFsmReference,
        junctions = {},
        handlers = {}
      }

      -- public methods access object
      local public = {}

      --------------------------------------------------------------------
      -- Adds handler to events in particular state.
      --
      -- @param             eventType - possible values are ("onEnter", "onExit", "onUpdate").
      -- @param             handlerFunction - function, that will be called when specified event occurs.
      public.addHandler = function(eventType, handlerFunction)

        assert(type(eventType) == "string")
        assert(type(handlerFunction == "function"))

        if not self.handlers[eventType] then self.handlers[eventType] = {} end

        self.handlers[eventType][#self.handlers[eventType] + 1] = handlerFunction

      end

      ---------------------------------------------------------------------------------
      -- Adds junction, to state instance.
      --
      -- @param conditon    function which should return true, when state
      --                    transition should be performed.
      -- @param targetState state, to which transition occurs.
      public.addJunction = function (condition, targetState)

        assert(type(condition) == "function")
        assert(type(targetState) == "string")

        self.junctions[#self.junctions + 1] =  {
          ["condition"] = condition,
          ["targetState"] = targetState
        }

      end

      ----------------------------------------------------------------------------------
      -- Triggers current state onUpdate handlers.
      --
      public.update = function ()
        self.callHandlers("onUpdate")
      end


      -----------------------------------------------------------------------------------
      -- Triggers onEnter handlers.
      --
      public.enter = function ()
        self.callHandlers("onEnter")
      end


      ------------------------------------------------------------------------------------
      -- Triggers onExit handlers.
      --
      public.exit = function ()
        self.callHandlers("onExit")
      end

      -----------------------------------------------------------
      -- State name getter.
      -- 
      public.getName = function ()
        return self.name
      end
      
      ---------------------------------------------------------------
      -- Processes all existing current state's junctions.
      -- 
      public.processJunctions = function ()
      	if self.junctions then
      		for i, junction in ipairs(self.junctions) do
      		  if junction.condition() then 
      		    return self.fsm.setNewState(junction.targetState)
      		    end
      		end
      	end
      end

      -----------------------------------------------------------------------------------
      -- Private parameterized state update method.
      --
      -- @param #string eventId one of three following event identifiers: onEnter, onExit, onUpdate
      --
      self.callHandlers = function (eventId)

        local isValidArguments = (eventId == "onEnter") or (eventId == "onExit") or (eventId == "onUpdate")
        assert(isValidArguments, "eventId should be one of 'onEnter', 'onExit', 'onUpdate'")

        if self.handlers[eventId] then
          for i, handler in ipairs(self.handlers[eventId]) do
            handler()
          end
        end

      end

      return public

    end
}

-----------------------------------------------------------------------------------------------
-- Junction class
--
M.Junction = {

    ----------------------------------------------------------------------------------------------
    -- Returns callback, that will add junction to parent fsm when setCondition method
    -- will be called.
    --
    createJunction = function(state1, state2, enclosingFsm)

      local self = {
        state1 = state1,
        state2 = state2,
        enclosingFsm = enclosingFsm
      }

      local public = {}

      ----------------------------------------------------------------------------------------------
      -- Sets condition which will triggers transition from state1 to state2 when becomes true.
      --
      public.setCondition = function (condition)
        self.enclosingFsm.addJunction(state1, state2, condition)
      end

      setmetatable(public, M.Junction)

      return public
    end

}

--------------------------------------------------------------------
-- Returns new FSM instance.
--
--
function M.createFSM()

  -- private methods and variables
  local self = {
    keys = {},
    states = {}
  }

  -- public methods and variables access object
  local fsm_public = {}

  ------------------------------------------------------------------------------
  -- Adds new state to current final state machine.
  --
  -- If current fsm instance has no states, than it automatically transitions to
  -- newly created state.
  --
  -- @param #string name_id name of state, that will be created.
  fsm_public.addState = function (name_id)

    local state = M.State.createState(name_id, fsm_public)
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

    if not condition then return M.Junction.createJunction(state_id1,state_id2,fsm_public) end

    local state = self.states[state_id1]
    state.addJunction(condition, state_id2)

  end
  
  -------------------------------------------------------------
  -- fsm key setter.
  fsm_public.setKey = function (keyId, newValue)
    self.keys[keyId] = newValue
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

  local junction = M.Junction.createJunction(state1.getName(), state2.getName(), fsm)
  junction.setCondition(function(state1, keys) return true end)
  
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
