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


return M
