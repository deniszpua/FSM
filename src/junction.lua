-----------------------------------------------------------------------------------------------
-- Junction class
-- @module junction - represents junction class.
--
local M = {}




----------------------------------------------------------------------------------------------
-- Returns callback, that will add junction to parent fsm when setCondition method
-- will be called.
-- @callof #junction module
local function createJunction(state1, state2, enclosingFsm)

  local self = {
    state1 = state1,
    state2 = state2,
    enclosingFsm = enclosingFsm
  }
  ----------------------------------------------------------------------------------------------
  -- Sets condition which will triggers transition from state1 to state2 when becomes true.
  --
  local function setCondition(condition)
    self.enclosingFsm.addJunction(state1, state2, condition)
  end

  return {setCondition = setCondition}
end

setmetatable(M, {__call=createJunction})

return M
