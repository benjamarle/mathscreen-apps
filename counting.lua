--! title: Counting
--! icon: 123
--! color: #27AE60
-- Count the dots, tap the right number.

local colors = { "red", "blue", "orange", "purple", "teal" }
local stars = 0

local function pick_options(answer)
  local opts = { answer }
  while #opts < 3 do
    local v = math.random(1, 10)
    local dup = false
    for _, o in ipairs(opts) do
      if o == v then dup = true end
    end
    if not dup then opts[#opts + 1] = v end
  end
  for i = #opts, 2, -1 do
    local j = math.random(i)
    opts[i], opts[j] = opts[j], opts[i]
  end
  return opts
end

local function question()
  ui.clear()
  ui.title("How many?")
  ui.label{ text = ui.sym.ok .. " " .. stars, align = "top_right", x = -10, y = 8, size = 16, color = "orange" }

  local n = math.random(1, 10)
  ui.dots{ n = n, r = 13, gap = 8, w = 240, align = "center", y = -28, bg = colors[math.random(#colors)] }

  ui.choices{
    options = pick_options(n), w = 300, h = 62, align = "bottom", y = -10, size = 36,
    on_pick = function(self, i, text)
      local ok = tonumber(text) == n
      self:mark(i, ok and "green" or "red")
      if ok then stars = stars + 1 end
      ui.feedback(ok, ok and ("Yes, " .. n .. "!") or ("It was " .. n), question)
    end,
  }
end

question()
