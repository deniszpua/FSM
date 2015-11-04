----------------------------------------------------------------
-- FSM State module unit test
--

local M = {}

local State = require("main.state")
local Assertions = require("testing.assertions")


-- state instance under test
local state


local function before()
	state = State("state 1", {keys = {}}) 
end


--------------------------------------------------------------------
-- It should save and call state's onEnter handlers
-- 
M.testOnEnterHandlers = function ()
	before()
	
	local onEnterHandlersMock = {isExecuted = false}
	state.addHandler('onEnter', 
	         function () onEnterHandlersMock.isExecuted = true end)
  state.enter()
	         
 return Assertions.assertEquals(true, onEnterHandlersMock.isExecuted)
end

--------------------------------------------------------------------
-- It should save and call state's onExit handlers
-- 
M.testOnExitHandlers = function ()
	before()
	
	local onEnterHandlersMock = {isExecuted = false}
	state.addHandler('onExit', 
	         function () onEnterHandlersMock.isExecuted = true end)
  state.exit()
	         
 return Assertions.assertEquals(true, onEnterHandlersMock.isExecuted)
end

--------------------------------------------------------------------
-- It should save and call state's onUpdate handlers
-- 
M.testOnUpdateHandlers = function ()
	before()
	
	local onEnterHandlersMock = {isExecuted = false}
	state.addHandler('onUpdate', 
	         function () onEnterHandlersMock.isExecuted = true end)
  state.update()
	         
 return Assertions.assertEquals(true, onEnterHandlersMock.isExecuted)
end

--------------------------------------------------------------------
-- It should not call onExit and onUpdate handlers while executing
-- enter method.
M.testOnEnterOtherHandlersNotExecuted = function ()
	before()
	
	local handlersMock = {
	 isOnExitExecuted = false, 
	 isOnUpdateExecuted = false
 }
	state.addHandler('onExit', function () handlersMock.isOnExitExecuted = true end)
	state.addHandler('onUpdate', function () handlersMock.isOnUpdateExecuted = true end)
	state.enter()
	
	return Assertions.assertEquals(false, handlersMock.isOnExitExecuted or handlersMock.isOnUpdateExecuted)
	
end

--------------------------------------------------------------------
-- It should not call onEnter and onUpdate handlers while executing
-- exit method.
M.testOnExitOtherHandlersNotExecuted = function ()
	before()
	
	local handlersMock = {
	 isOnEnterExecuted = false, 
	 isOnUpdateExecuted = false
 }
	state.addHandler('onEnter', function () handlersMock.isOnEnterExecuted = true end)
	state.addHandler('onUpdate', function () handlersMock.isOnUpdateExecuted = true end)
	state.exit()
	
	return Assertions.assertEquals(false, handlersMock.isOnEnterExecuted or handlersMock.isOnUpdateExecuted)
	
end

--------------------------------------------------------------------
-- It should not call onEnter and onExit handlers while executing
-- update method.
M.testOnUpdateOtherHandlersNotExecuted = function ()
	before()
	
	local handlersMock = {
	 isOnEnterExecuted = false, 
	 isOnExitExecuted = false
 }
	state.addHandler('onEnter', function () handlersMock.isOnEnterExecuted = true end)
	state.addHandler('onExit', function () handlersMock.isOnExitExecuted = true end)
	state.update()
	
	return Assertions.assertEquals(false, handlersMock.isOnEnterExecuted or handlersMock.isOnExitExecuted)
	
end

------------------------------------------------------------------------
-- It should check all its junctions while executing processJunction method.
-- 
M.testIsJunctionCheckWhileUpdate = function ()
  before()
  
  local callback = {
    isFirstJunctionExecuted = false,
    isSecondJunctionExecuted = false,
    isThirdJunctionExecuted = false
    }
    
    state.addJunction(
        function (state, keys)
        	callback.isFirstJunctionExecuted = true 
        	return false
        end,
        'another state')
    state.addJunction(
        function (state, keys)
        	callback.isSecondJunctionExecuted = true 
        	return false
        end,
        'another state')
    state.addJunction(
        function (state, keys)
        	callback.isThirdJunctionExecuted = true 
        	return false
        end,
        'another state')
    state.processJunctions()
    
    return Assertions.assertEquals(true, callback.isFirstJunctionExecuted and
            callback.isSecondJunctionExecuted and callback.isThirdJunctionExecuted)
end



return M
