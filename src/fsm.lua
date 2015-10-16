-------------------------------------------------------------
-- Module, that represents finite state machine
--
-- @module fsm
------------------------------------------------------------
local M = {}

local print = print
local assert = assert
local type = type

--_ENV = M


--------------------------------------------------------------------
-- Returns new FSM instance.
--
--
function M.createFSM()

  local instance = {}

  instance.addState = function (self, name_id)

    if not self.states then self.states = {} end

    local state = {}
    state.name = name_id
    state.addEventHandler = function (self, eventId, eventHandler)

      assert(type(eventHandler == "function"))
      assert(type(eventId) == "string")

      if not state.handlers then state.handlers = {} end
      if not state.handlers[eventId] then state.handlers[eventId] = {} end

      state.handlers[eventId][#state.handlers[eventId] + 1] = eventHandler

    end

    self.states[#self.states + 1] = state
    return state
  end
  
  instance.addJunction = function (self, state_id1, state_id2)
  	
  	local junction = {}
  	if not self.junctions then self.junctions = {} end
  	
  	self.junctions[#self.junctions + 1] = junction
  	
  	
  	return junction
  end
  
  return instance
end

  ------------------------------------------
  -- unit test
  ------------------------------------------
local function main()

  --
  local fsm_instance = M.createFSM()
  local state = fsm_instance:addState("init")
  state:addEventHandler("onEnter", function() print("Init state onEnter handler") end)
  
  local junction = fsm_instance.addJunction("init", "running")
  

end

main()

return M
