-------------------------------------------------------------------------------------------
--
-- @

local M = {}

local assert = assert
local type = type
local ipairs = ipairs

__ENV = M

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

return M