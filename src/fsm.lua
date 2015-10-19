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

--_ENV = M

---------------------------------------------------------------------
-- Returns fsm state instance
--
--
M.createState = function (state_name, enclosingFsmReference)

  -- private instance variables container
  local self = {name = state_name, fsm = enclosingFsmReference}

  -- public methods access object
  local methods = {}

  --------------------------------------------------------------------
  -- Adds handler to events in particular state.
  --
  -- @param             eventType - possible values are ("onEnter", "onExit", "onUpdate").
  -- @param             handlerFunction - function, that will be called when specified event occurs.
  methods.addHandler = function(eventType, handlerFunction)

    assert(type(eventType) == "string")
    assert(type(handlerFunction == "function"))

    if not self.handlers then self.handlers = {} end
    if not self.handlers[eventType] then self.handlers[eventType] = {} end

    self.handlers[eventType][#self.handlers[eventType] + 1] = handlerFunction

  end

  ---------------------------------------------------------------------------------
  -- Adds junction, to state instance.
  --
  -- @param conditon    function which should return true, when state
  --                    transition should be performed.
  -- @param targetState state, to which transition occurs.
  methods.addJunction = function (condition, targetState)

    assert(type(condition) == "function")
    assert(type(targetState) == "table")

    if not self.conditions then self.conditions = {} end

    self.conditions[#self.conditions + 1] = condition

  end

  ----------------------------------------------------------------------------------
  -- Triggers current state onUpdate handlers.
  --
  methods.update = function ()
    local handlers = self.handlers["onUpdate"]
    
    if handlers then

      for i, handler in ipairs(handlers) do
        handler()
      end
    end
  end

  return methods

end


--------------------------------------------------------------------
-- Returns new FSM instance.
--
--
function M.createFSM()

  local self = {}

  local addState = function (self, name_id)

    if not self.states then self.states = {} end

    self.states[name_id] = M.createState(name_id)

  end

  local addJunction = function (self, state_id1, state_id2)

    local junction = {}
    if not self.junctions then self.junctions = {} end

    self.junctions[#self.junctions + 1] = junction

    junction.setCondition = function (self, stateChangeCondition)

      assert(type(stateChangeCondition) == "function")



    end


    return junction
  end

  return {
    addState = addState,
    addJunction = addJunction
  }
end

------------------------------------------
-- unit test
------------------------------------------
local function main()

  --
  local newState = M.createState("initial State")

  newState.addHandler("onEnter", function() print("Init state onEnter handler") end)
  
  newState.update()

  --  local fsm_instance = M.createFSM()
  --  local state = fsm_instance:addState("init")
  --  state:addEventHandler("onEnter", function() print("Init state onEnter handler") end)
  --
  --  local junction = fsm_instance:addJunction("init", "running")


end

main()

return M
