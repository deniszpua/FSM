-------------------------------------------------------------------------------------------
-- FSM State class representing module
-- @module state

local M = {}




    -------------------------------------------------------------------------------------------------
    -- State objects factory method.
    -- @callof #state module
    function M.createState(stateName, enclosingFsmReference)

      -- private instance variables container
      local self = {
        name = stateName,
        fsm = enclosingFsmReference,
        junctions = {},
        handlers = {}
      }

      --------------------------------------------------------------------
      -- Adds handler to events in particular state.
      --
      -- @param             eventType - possible values are ("onEnter", "onExit", "onUpdate").
      -- @param             handlerFunction - function, that will be called when specified event occurs.
      local function addHandler(eventType, handlerFunction)

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
      local function addJunction(condition, targetState)

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
      local function update()
        self.callHandlers("onUpdate")
      end


      -----------------------------------------------------------------------------------
      -- Triggers onEnter handlers.
      --
      local function enter()
        self.callHandlers("onEnter")
      end


      ------------------------------------------------------------------------------------
      -- Triggers onExit handlers.
      --
      local function exit()
        self.callHandlers("onExit")
      end

      -----------------------------------------------------------
      -- State name getter.
      -- 
      local function getName()
        return self.name
      end
      
      ---------------------------------------------------------------
      -- Processes all existing current state's junctions.
      -- 
      local function processJunctions()
        if self.junctions then
          for i, junction in ipairs(self.junctions) do
            if junction.condition(public, enclosingFsmReference.keys) then 
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

      return {
        addHandler = addHandler,
        addJunction = addJunction,
        enter = enter,
        exit = exit,
        update = update,
        getName = getName,
        processJunctions = processJunctions 
      }

    end

setmetatable(M, {__call=M.createState})
return M