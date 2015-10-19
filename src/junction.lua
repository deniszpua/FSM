-----------------------------------------------------------------------------------------------
-- Junction class
-- @module junction - represents junction class.
-- 
local M = {}

__ENV = M
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

      return public
    end

}

return M