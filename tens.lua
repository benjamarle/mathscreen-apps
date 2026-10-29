--! title: Tens & Ones
--! icon: 47
--! color: #16A085
-- Place value. Alternates two rounds:
--   count: read a number from tens rods + ones cubes (distractors: swapped digits, +-10, +-1)
--   build: make a number with +10 / +1; ten ones regroup into a ten

local TEN_COLOR, ONE_COLOR = "blue", "orange"
local CUBE_W, CUBE_H, STEP_Y = 11, 9, 11   -- one cube; a rod is 10 cubes tall (110 px)
local ROD_STEP = 16                         -- horizontal spacing between rods
local stars = 0
local round_no = 0
local next_round

-- Draws t rods and u cubes centered at the top area; returns the created elements.
local function draw_blocks(t, u, top)
  local items = {}
  local ones_cols = u > 5 and 2 or (u > 0 and 1 or 0)
  local width = t * ROD_STEP + (t > 0 and ones_cols > 0 and 10 or 0) + ones_cols * (CUBE_W + 3)
  local x = math.floor((ui.W - width) / 2)

  for r = 0, t - 1 do
    for c = 0, 9 do
      items[#items + 1] = ui.box{ x = x + r * ROD_STEP, y = top + c * STEP_Y,
                                  w = CUBE_W, h = CUBE_H, bg = TEN_COLOR, radius = 2 }
    end
  end
  local ox = x + t * ROD_STEP + (t > 0 and 10 or 0)
  for i = 0, u - 1 do
    local col, row = i // 5, i % 5
    -- ones sit at the bottom, level with the rods' base
    items[#items + 1] = ui.box{ x = ox + col * (CUBE_W + 3), y = top + (9 - row) * STEP_Y,
                                w = CUBE_W, h = CUBE_H, bg = ONE_COLOR, radius = 2 }
  end
  return items
end

local function stars_label()
  ui.label{ text = ui.sym.ok .. " " .. stars, align = "top_right", x = -10, y = 8, size = 16, color = "orange" }
end

local function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

-- ---------- count round ----------

local function count_round()
  ui.clear()
  ui.title("How many?")
  stars_label()

  local t, u = math.random(1, 9), math.random(0, 9)
  local n = t * 10 + u
  draw_blocks(t, u, 36)

  -- distractors that catch place-value mix-ups
  local candidates = { u * 10 + t, n + 10, n - 10, n + 1, n - 1 }
  shuffle(candidates)
  local opts = { n }
  for _, v in ipairs(candidates) do
    if #opts == 3 then break end
    local fresh = v >= 1 and v <= 99 and v ~= n
    for _, o in ipairs(opts) do
      if o == v then fresh = false end
    end
    if fresh then opts[#opts + 1] = v end
  end
  shuffle(opts)

  ui.choices{
    options = opts, w = 300, h = 58, align = "bottom", y = -6, size = 36,
    on_pick = function(self, i, text)
      local ok = tonumber(text) == n
      self:mark(i, ok and "green" or "red")
      if ok then
        stars = stars + 1
        ui.feedback(true, t .. " tens + " .. u .. " ones = " .. n, next_round)
      else
        ui.feedback(false, t .. " tens + " .. u .. " ones = " .. n, next_round)
      end
    end,
  }
end

-- ---------- build round ----------

local function build_round()
  ui.clear()
  ui.title("Build it!")
  stars_label()

  local target = math.random(11, 99)
  ui.label{ text = "Make", size = 16, x = 12, y = 52, color = "gray" }
  ui.label{ text = target, size = 36, x = 10, y = 70, color = "navy" }

  local t, u = 0, 0
  local drawn = {}
  local note

  local function redraw()
    for _, e in ipairs(drawn) do e:delete() end
    drawn = draw_blocks(t, u, 52)
  end

  local function say(text)
    if note then note:delete() end
    note = ui.label{ text = text, size = 16, align = "top", y = 32, color = "purple" }
    local this = note
    ui.after(1800, function() this:delete() end)
  end

  ui.choices{
    options = { "-10", "+10", "-1", "+1", ui.sym.ok }, w = 308, h = 56, align = "bottom", y = -6,
    size = 24, gap = 6,
    on_pick = function(self, i, text)
      if i == 1 and t > 0 then t = t - 1
      elseif i == 2 and t < 9 then t = t + 1
      elseif i == 3 then
        if u > 0 then u = u - 1
        elseif t > 0 then t, u = t - 1, 9; say("1 ten = 10 ones")
        end
      elseif i == 4 then
        if u < 9 then u = u + 1
        elseif t < 9 then t, u = t + 1, 0; say("10 ones = 1 ten!")
        end
      elseif i == 5 then
        local made = t * 10 + u
        if made == target then
          stars = stars + 1
          ui.feedback(true, t .. " tens + " .. u .. " ones = " .. target, next_round)
        else
          ui.feedback(false, "You made " .. made .. ". Try again!")
        end
        return
      end
      redraw()
    end,
  }
  redraw()
end

next_round = function()
  round_no = round_no + 1
  if round_no % 2 == 1 then count_round() else build_round() end
end

next_round()
