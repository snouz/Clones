local lib = require("lib")

for _, char in pairs(data.raw.character) do
	if not lib.find(char.crafting_categories or {}, "hand-crafting") then
		char.crafting_categories = char.crafting_categories or {}
		table.insert(char.crafting_categories, "hand-crafting")
	end
end
