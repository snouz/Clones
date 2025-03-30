require ("prototypes.cloning-machine")

data:extend({
  {
    type = "recipe-category",
    name = "cloning",
  },
  {
    type = "custom-input",
    name = "clones-switch-character-next",
    key_sequence = "N",
    consuming = "game-only",
    action = "lua",
  },
  {
    type = "custom-input",
    name = "clones-switch-character-previous",
    key_sequence = "CONTROL + N",
    consuming = "game-only",
    action = "lua",
  },
  {
    type = "virtual-signal",
    name = "mainplayer_character",
    icons = {{icon = "__Clones__/graphics/icons/character.png", size = 64, scale = 0.2}},
    subgroup = "virtual-signal-special",
    order = "a[special]-[1everything]",
    hidden = true,
    hidden_in_factoriopedia = true,
  },
  {
    type = "virtual-signal",
    name = "clone_character",
    icons = {{icon = "__Clones__/graphics/icons/clone-character.png", size = 64, scale = 0.2}},
    subgroup = "virtual-signal-special",
    order = "a[special]-[1everything]",
    hidden = true,
    hidden_in_factoriopedia = true,
  },
  {
    type = "virtual-signal",
    name = "clone_machine",
    icons = {{icon = "__Clones__/graphics/icons/clone-machine.png", size = 64, scale = 0.2}},
    subgroup = "virtual-signal-special",
    order = "a[special]-[1everything]",
    hidden = true,
    hidden_in_factoriopedia = true,
  },
  --[[{
    type = "recipe",
    name = "clones-clone",
    icon = "__Clones__/graphics/icons/cloning.png",
    enabled = false,
    energy_required = 5,
    -- energy_required = 1,
    ingredients = {
      --{ type = "item", name = "nutrients", amount = 50 },
      --{ type = "item", name = "bioflux", amount = 25 },
      {type = "item", name = "iron-plate", amount = 1},
    },
    results = {{type = "item", name = "clones-clone", amount = 1}},
    category = "cloning",
    subgroup = "transport",
    order = "a",
  },
  {
    type = "item",
    name = "clones-clone",
    icon = "__Clones__/graphics/icons/cloning.png",    subgroup = "intermediate-product",
    order = "h[clones-clone]",
    stack_size = 1,
  },]]
  {
    type = "technology",
    name = "character-cloning",
    icon = "__Clones__/graphics/technology/clones-technology.png",
    icon_size = 256,
    effects = {
      --{
      --  type = "unlock-recipe",
      --  recipe = "clones-clone",
      --},
      {
        type = "unlock-recipe",
        recipe = "cloning-machine",
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
