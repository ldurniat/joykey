-- joykey 0.1

-- Re-broadcast joystick axis events as arrow keys

-- this module turns gamepad axis events into keyboard
-- events so we don't have to write separate code
-- for joystick and keyboard control

-- just add this line to your main.lua
-- require("com.ponywolf.joykey").start()

local M = {}
local deadZone = 0.333

-- store previous events
local eventCache = {}

-- store key mappings
local map = {}

-- map the axis to arrow keys and wsad
map["axis1-"] = "left"
map["axis1+"] = "right"
map["axis2-"] = "up"
map["axis2+"] = "down"

map["axis3-"] = "a"
map["axis3+"] = "d"
map["axis4-"] = "w"
map["axis4+"] = "s"

-- capture the axis event
local function axis(event)
  local num = event.axis.number or 1
  local name = "axis" .. num
  local value = event.normalizedValue
  local oppositeAxis = "none"

  event.name = "key" -- overide event type

  -- set map axis to key
  if value > 0 then
    event.keyName = map[name .. "+"]
    oppositeAxis = map[name .. "-"]
  elseif value < 0 then
    event.keyName = map[name .. "-"]
    oppositeAxis = map[name .. "+"]
  else
    -- we had an exact 0 so throw both key up events for this axis
    event.keyName = map[name .. "-"]
    oppositeAxis = map[name .. "+"]
  end

  if math.abs(value) > deadZone then
    -- throw the opposite axis if it was last pressed
    if eventCache[oppositeAxis] then
      event.phase = "up"
      eventCache[oppositeAxis] = false
      event.keyName = oppositeAxis
      Runtime:dispatchEvent(event)
    end
    -- throw this axis if it wasn't last pressed
    if not eventCache[event.keyName] then
      if event.keyName then
        event.phase = "down"
        eventCache[event.keyName] = true
        Runtime:dispatchEvent(event)
      end
    end
  else
    -- we're back toward center
    if eventCache[event.keyName] then
      event.phase = "up"
      eventCache[event.keyName] = false
      Runtime:dispatchEvent(event)
    end
    if eventCache[oppositeAxis] then
      event.phase = "up"
      eventCache[oppositeAxis] = false
      event.keyName = oppositeAxis
      Runtime:dispatchEvent(event)
    end
  end
  return true
end

function M.start()
  Runtime:addEventListener("joystick_axis", axis)
end

return M