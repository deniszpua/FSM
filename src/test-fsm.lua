-----------------------------------------------------------------------
-- Finite state machine unit test
-- @module test-fsm

local M = {}

local lunit = require("lunit")
local fsm = require("fsm")

__ENV = M


local fsm_instance, state1, state2

local function before()
  fsm_instance = fsm.createFSM()
  state1 = fsm_instance.addState("state 1")
  state2 = fsm_instance.addState("state 2")

  fsm_instance.addJunction("state 1", "state 2",
    function (state, keys) return keys.myVar == "move to state2" end)
end
---------------------------------------------------------------------
-- It should transition from one state to another, when junction
-- condition holds.
M.testTransitionBetweenStates = function ()

  before()

  fsm_instance.setKey("myVar", "move to state2")
  return lunit.assertEquals("state 2",fsm_instance.getCurrentStateId())
end

-----------------------------------------------------------------------
-- It should call onExit handlers when transitioning from handler's
-- enclosing state to another.
-- 
M.testCallOnExitHandlers = function ()
	before()
	
	local isHandlerExecuted = {flag = false}
	state1.addHandler('onExit', function() isHandlerExecuted.flag = true end)
  fsm_instance.setKey("myVar", "move to state2")
  return lunit.assertEquals(true, isHandlerExecuted.flag)
end

-------------------------------------------------------------------------
-- It should call onEnter handlers when transitioning to handler's 
-- enclosing state.
-- 
M.testCallOnEnterExecuted = function ()
	before()
	
	local isHandlerExecuted = {flag = false}
	state2.addHandler('onEnter', function() isHandlerExecuted.flag = true end)
  fsm_instance.setKey("myVar", "move to state2")
  return lunit.assertEquals(true, isHandlerExecuted.flag)
end 



return M

