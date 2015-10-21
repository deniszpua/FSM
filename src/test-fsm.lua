-----------------------------------------------------------------------
-- Finite state machine unit test
-- @module test-fsm

local M = {}

local lunitModule = require("lunit")
local fsmModule = require("fsm")

__ENV = M


-- FSM instance under test
local fsm_instance
  -- initial state
local state1
  -- target state, in case of testing transition, or inactive state otherwise
local state2

local function before()
  fsm_instance = fsmModule.createFSM()
  
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
  return lunitModule.assertEquals("state 2",fsm_instance.getCurrentStateId())
end

-----------------------------------------------------------------------
-- It should call onExit handlers when transitioning from handler's
-- enclosing state to another.
-- 
M.testCallOnExitHandlers = function ()
	before()
	
	local handlersMock = {isExecuted = false}
	state1.addHandler('onExit', function() handlersMock.isExecuted = true end)
  fsm_instance.setKey("myVar", "move to state2")
  return lunitModule.assertEquals(true, handlersMock.isExecuted)
end

-------------------------------------------------------------------------
-- It should call onEnter handlers when transitioning to handler's 
-- enclosing state.
-- 
M.testCallOnEnterExecuted = function ()
	before()
	
	local handlersMock = {isExecuted = false}
	state2.addHandler('onEnter', function() handlersMock.isExecuted = true end)
  fsm_instance.setKey("myVar", "move to state2")
  return lunitModule.assertEquals(true, handlersMock.isExecuted)
end 


--------------------------------------------------------------------------
-- It should call current state onUpdate handlers when calling enclosing
-- fsm update method.
-- 
M.testCallOnUpdateExecuted = function ()
  before()
  	
	local handlersMock = {isExecuted = false}
	state1.addHandler('onUpdate', function() handlersMock.isExecuted = true end)
  return lunitModule.assertEquals(true, handlersMock.isExecuted)
end 

--------------------------------------------------------------------------
-- It should not call inactive state onUpdate handlers when calling enclosing
-- fsm update method.
-- 
M.testCallOnUpdateExecuted = function ()
  before()
  	
	local handlersMock = {isExecuted = false}
	state2.addHandler('onUpdate', function() handlersMock.isExecuted = true end)
  return lunitModule.assertEquals(false, handlersMock.isExecuted)
end 

--------------------------------------------------------------------------------
-- It should check all junctions when executing fsm on Update methods
-- 
M.testJunctionsExecutedOnUpdate = function ()
	before()
	
	local junctionMock = {isExecuted = false}
	fsm_instance.addJunction('state 1', 'state 2', 
	   function (state, keys) junctionMock.isExecuted = true return false end)
   fsm_instance.update()
  return lunitModule.assertEquals(true, junctionMock.isExecuted)
end


---------------------------------------------------------------------------------
-- It should change its state if junction's condition holds true, while performing
-- update.
-- 
M.testChangesStateOnUpdate = function ()
	before()
	
	fsm_instance.addJunction('state 1', 'state 2', 
	                         function (state, keys) return true end)
   fsm_instance.update()
  return lunitModule.assertEquals('state 2', fsm_instance.getCurrentStateId())
	
end

return M

