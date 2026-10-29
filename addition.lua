--! title: Add it up
--! icon: 3+4
--! color: #2E86DE
-- Additions up to 10 on the number pad; remembers the best streak.

local best = store.get("best", 0)
local streak = 0
local a, b, pad

local problem = ui.label{ text = "", size = 36, align = "top", y = 34 }

local function show(typed)
  problem:set_text(a .. " + " .. b .. " = " .. (typed ~= "" and typed or "?"))
end

local function new_question()
  a = math.random(1, 9)
  b = math.random(1, 10 - a)
  pad:clear()
  show("")
  ui.title("Best streak: " .. best)
end

pad = ui.keypad{
  max = 2,
  on_change = function(self, text) show(text) end,
  on_submit = function(self, n)
    local ok = n == a + b
    streak = ok and streak + 1 or 0
    if streak > best then
      best = streak
      store.set("best", best)
    end
    ui.feedback(ok, ok and ("Streak: " .. streak) or ("It was " .. (a + b)), new_question)
  end,
}

new_question()
