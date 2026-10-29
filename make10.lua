--! title: Make 10 & 100
--! icon: +?=
--! color: #8E44AD
-- Drag the missing number into the box. Levels go up after 3 right in a row
-- and back down after 2 wrong in a row:
--   1: n + ? = 10          (7 + 3)
--   2: tens + ? = 100      (30 + 70)
--   3: up to the next ten  (47 + 3 = 50)
--   4: n + ? = 100         (37 + 63)

local LEVELS = {
  { name = "Make 10" },
  { name = "Make 100 with tens" },
  { name = "Next ten" },
  { name = "Make 100" },
}
local level = math.tointeger(store.get("level", 1)) or 1
level = math.max(1, math.min(level, 4))
local streak, misses = 0, 0

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

-- Returns start, total, and wrong answers that match typical mistakes.
local function make_problem()
  if level == 1 then
    local n = math.random(1, 9)
    return n, 10, { 10 - n + 1, 10 - n - 1, n }
  elseif level == 2 then
    local n = math.random(1, 9) * 10
    return n, 100, { 100 - n + 10, 100 - n - 10, n }
  elseif level == 3 then
    local n = math.random(1, 9) * 10 + math.random(1, 9)
    local total = (n // 10 + 1) * 10
    local need = total - n
    return n, total, { need + 1, need - 1, 10 - need, need + 10 }
  else
    local n = math.random(1, 9) * 10 + math.random(1, 9)
    local need = 100 - n
    local tens, ones = n // 10, n % 10
    -- classic slip: making each digit up to 10 (37 -> 73, which gives 110)
    local digit_slip = (10 - tens) * 10 + (10 - ones)
    return n, 100, { digit_slip, need + 10, need - 10, need + 1 }
  end
end

local function pick_options(need, wrong)
  local opts = { need }
  shuffle(wrong)
  for _, v in ipairs(wrong) do
    if #opts == 3 then break end
    local fresh = v > 0 and v < 100 and v ~= need
    for _, o in ipairs(opts) do
      if o == v then fresh = false end
    end
    if fresh then opts[#opts + 1] = v end
  end
  while #opts < 3 do  -- top up if the mistakes were out of range or duplicates
    local v = need + math.random(-12, 12)
    local fresh = v > 0 and v < 100 and v ~= need
    for _, o in ipairs(opts) do
      if o == v then fresh = false end
    end
    if fresh then opts[#opts + 1] = v end
  end
  shuffle(opts)
  return opts
end

local round

local function result(ok)
  if ok then
    streak, misses = streak + 1, 0
    if streak >= 3 and level < #LEVELS then
      level, streak = level + 1, 0
      store.set("level", level)
      return "Level up!"
    end
  else
    streak, misses = 0, misses + 1
    if misses >= 2 and level > 1 then
      level, misses = level - 1, 0
      store.set("level", level)
    end
  end
end

round = function()
  ui.clear()
  ui.title("Level " .. level .. ": " .. LEVELS[level].name)

  local n, total, wrong = make_problem()
  local need = total - n

  ui.label{ text = n .. " +", size = 36, align = "top_right", x = -212, y = 66 }
  local target = ui.box{ w = 84, h = 70, x = 114, y = 50, bg = "white", radius = 14, border = 3,
                         border_color = "purple" }
  ui.label{ text = "= " .. total, size = 36, x = 208, y = 66 }

  -- progress towards the next level
  for i = 1, 3 do
    ui.circle{ r = 5, x = 270 + i * 13, y = 12, bg = i <= streak and "orange" or "gray" }
  end

  for i, v in ipairs(pick_options(need, wrong)) do
    local x0, y0 = 22 + (i - 1) * 100, 158
    local tile = ui.box{ text = v, w = 76, h = 64, x = x0, y = y0, bg = "orange", color = "white",
                         size = 36, radius = 14 }
    tile:draggable(function(self)
      if not self:overlaps(target) then
        self:move_to(x0, y0, 250)
      elseif v == need then
        self:move_to(118, 53, 150, function()
          local extra = result(true)
          ui.feedback(true, n .. " + " .. v .. " = " .. total .. (extra and ("\n" .. extra) or ""), round)
        end)
      else
        result(false)
        ui.feedback(false, n .. " + " .. v .. " = " .. (n + v), function()
          self:move_to(x0, y0, 250)
        end)
      end
    end)
  end
end

round()
