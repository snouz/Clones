data:extend({
	{
		type = "recipe-category",
		name = "hand-crafting",
	},
	{
		type = "custom-input",
		name = "clones-switch-character",
		key_sequence = "SHIFT + TAB",
		consuming = "game-only",
		action = "lua",
	},
	{
		type = "recipe",
		name = "clones-clone",
		enabled = false,
		energy_required = 5,
		-- energy_required = 1,
		ingredients = {
			{ type = "item", name = "nutrients", amount = 50 },
			{ type = "item", name = "bioflux", amount = 25 },
		},
		results = { { type = "item", name = "clones-clone", amount = 1 } },
		category = "hand-crafting",
		subgroup = "transport",
		order = "a",
	},
	{
		type = "item",
		name = "clones-clone",
		icon = data.raw.character.character.icon,
		icon_size = data.raw.character.character.icon_size or 64,
		subgroup = "intermediate-product",
		order = "h[clones-clone]",
		stack_size = 1,
	},
	{
		type = "technology",
		name = "character-cloning",
		icon = data.raw.character.character.icon,
		icon_size = data.raw.character.character.icon_size or 64,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "clones-clone",
			},
		},
		prerequisites = { "agricultural-science-pack" },
		unit = {
			count = 1000,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "space-science-pack", 1 },
				{ "agricultural-science-pack", 1 },
			},
			time = 60,
		},
	},
})
