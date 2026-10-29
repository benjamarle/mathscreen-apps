--! title: Doubles & Halves
--! icon: x2
--! color: #E67E22
-- Double n, or halve 2n, where n goes up to 10 on level 1, 20 on level 2, ... 100 on level 10.
-- Most questions use the numbers new to the level, some review the lower ones.
-- 5 right in a row: level up. 2 wrong in a row: level down. Level is saved.

local MAX_LEVEL = 10
local UP_STREAK = 5
local level = math.tointeger(store.get("level", 1)) or 1
level = math.max(1, math.min(level, MAX_LEVEL))
local streak, misses = 0, 0

local question  -- forward declaration

local function pick_base()
  local top = level * 10
  local lo = level == 1 and 1 or top - 9
  if math.random() < 0.3 then lo = 1 end  -- review
  return math.random(lo, top)
end

local function score(ok)
  if ok then
    streak, misses = streak + 1, 0
    if streak >= UP_STREAK and level < MAX_LEVEL then
      level, streak = level + 1, 0
      store.set("level", level)
      return "\nLevel up! Up to " .. level * 10
    end
  else
    streak, misses = 0, misses + 1
    if misses >= 2 and level > 1 then
      level, misses = level - 1, 0
      store.set("level", level)
    end
  end
  return ""
end

question = function()
  ui.clear()
  ui.title("Level " .. level .. ": up to " .. level * 10)
  for i = 1, UP_STREAK do
    ui.circle{ r = 5, x = 250 + i * 13, y = 12, bg = i <= streak and "orange" or "gray" }
  end

  local n = pick_base()
  local doubling = math.random() < 0.5
  local asked = doubling and n or n * 2
  local answer = doubling and n * 2 or n
  local prompt = doubling and ("Double " .. asked) or ("Half of " .. asked)
  local explain = doubling and (n .. " + " .. n .. " = " .. answer)
                            or (n .. " + " .. n .. " = " .. asked)

  ui.label{ text = prompt, size = 24, w = 160, x = 2, y = 44, color = doubling and "blue" or "purple" }
  local shown = ui.label{ text = "= ?", size = 36, w = 160, x = 2, y = 86 }

  -- On level 1 the numbers are small enough to draw.
  if level == 1 then
    if doubling then
      ui.dots{ n = n, r = 6, gap = 4, w = 160, x = 2, y = 150, bg = "blue" }
      ui.dots{ n = n, r = 6, gap = 4, w = 160, x = 2, y = 150 + (n > 10 and 32 or 18), bg = "blue" }
    else
      ui.dots{ n = asked, r = 6, gap = 4, w = 160, x = 2, y = 150, bg = "purple" }
    end
  end

  ui.keypad{
    max = 3, w = 156, h = 196, align = "bottom_right", x = -2, y = -2,
    on_change = function(self, text)
      shown:set_text("= " .. (text ~= "" and text or "?"))
    end,
    on_submit = function(self, value)
      local ok = value == answer
      local extra = score(ok)
      if ok then
        ui.feedback(true, prompt .. " = " .. answer .. extra, question)
      else
        ui.feedback(false, prompt .. " = " .. answer .. "\n" .. explain, question)
      end
    end,
  }
end

question()
