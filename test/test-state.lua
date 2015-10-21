----------------------------------------------------------------
-- FSM State module unit test
--

local M = {}

local state_module = require("state")
local lunit_module = require("lunit")

__ENV = M

-- state instance under test
local state_instance


local function before()
	state_instance = state_module.State.createState("state 1",nill) 
end


--------------------------------------------------------------------
-- It should save and call state's onEnter handlers
-- 
M.testOnEnterHandlers = function ()
	before()
	
	local onEnterHandlersMock = {isExecuted = false}
	state_instance.addHandler('onEnter', 
	         function () onEnterHandlersMock.isExecuted = true end)
  state_instance.enter()
	         
 return lunit_module.assertEquals(true, onEnterHandlersMock.isExecuted)
end

--------------------------------------------------------------------
-- It should save and call state's onExit handlers
-- 
M.testOnExitHandlers = function ()
	before()
	
	local onEnterHandlersMock = {isExecuted = false}
	state_instance.addHandler('onExit', 
	         function () onEnterHandlersMock.isExecuted = true end)
  state_instance.exit()
	         
 return lunit_module.assertEquals(true, onEnterHandlersMock.isExecuted)
end

--------------------------------------------------------------------
-- It should save and call state's onUpdate handlers
-- 
M.testOnUpdateHandlers = function ()
	before()
	
	local onEnterHandlersMock = {isExecuted = false}
	state_instance.addHandler('onUpdate', 
	         function () onEnterHandlersMock.isExecuted = true end)
  state_instance.update()
	         
 return lunit_module.assertEquals(true, onEnterHandlersMock.isExecuted)
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
	state_instance.addHandler('onExit', function () handlersMock.isOnExitExecuted = true end)
	state_instance.addHandler('onUpdate', function () handlersMock.isOnUpdateExecuted = true end)
	state_instance.enter()
	
	return lunit_module.assertEquals(false, handlersMock.isOnExitExecuted or handlersMock.isOnUpdateExecuted)
	
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
	state_instance.addHandler('onEnter', function () handlersMock.isOnEnterExecuted = true end)
	state_instance.addHandler('onUpdate', function () handlersMock.isOnUpdateExecuted = true end)
	state_instance.exit()
	
	return lunit_module.assertEquals(false, handlersMock.isOnEnterExecuted or handlersMock.isOnUpdateExecuted)
	
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
	state_instance.addHandler('onEnter', function () handlersMock.isOnEnterExecuted = true end)
	state_instance.addHandler('onExit', function () handlersMock.isOnExitExecuted = true end)
	state_instance.update()
	
	return lunit_module.assertEquals(false, handlersMock.isOnEnterExecuted or handlersMock.isOnExitExecuted)
	
end



return M
