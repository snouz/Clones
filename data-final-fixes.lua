--local lib = require("lib")

--[[
for _, char in pairs(data.raw.character) do
  if not lib.find(char.crafting_categories or {}, "cloning") then
    char.crafting_categories = char.crafting_categories or {}
    table.insert(char.crafting_categories, "cloning")
  end

  char.created_effect = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        type = "script",
        effect_id = "clones-character-created",
      },
    },
  }
end]]
