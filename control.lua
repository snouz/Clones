local Public = {}
--current_global_character 




--local function spawn_clone_with_cloning_machine()

--end

script.on_event(defines.events.on_built_entity, function(event)
  if event.entity and event.entity.name == "cloning-machine" then
    local machine = event.entity
    --spawn_clone_with_cloning_machine()

    local player = game.players[event.player_index]
    if not (player and player.character and player.character.valid) then
      return
    end

    -- Store characters associated with the player
    storage.characters = storage.characters or {}
    storage.characters[player.index] = storage.characters[player.index] or {}
    storage.currentclonenumber = storage.currentclonenumber or {}
    storage.currentclonenumber[player.index] = storage.currentclonenumber[player.index] or 1

    -- set index of active character
    local current_character = player.character
    local current_character_found = false
    local current_index = 1
    for i, char in ipairs(storage.characters[player.index]) do
      if char == current_character then
        current_character_found = true
        current_index = i
        break
      end
    end
    -- If not found, add character storage
    if not current_character_found then
      table.insert(storage.characters[player.index], current_character)
      current_index = #storage.characters[player.index]
    end




    local pos = machine.surface.find_non_colliding_position("character", {machine.position.x , machine.position.y + 1.5}, 100, 0.3)

    if pos then
      -- Create the cloned character entity
      local clone = machine.surface.create_entity({
        name = player.character.name, -- .. " (Clone #" .. current_index - 1 .. ")",
        position = pos,
        force = player.force,
        direction = defines.direction.south,
        move_stuck_players = true,
        create_build_effect_smoke = true,
        --name_tag = {currentclonenumber = tostring(storage.currentclonenumber[player.index])}
      })
      clone.name_tag = tostring(storage.currentclonenumber[player.index])

      -- Store the clone
      table.insert(storage.characters[player.index], current_index + 1, clone)
      storage.currentclonenumber[player.index] = storage.currentclonenumber[player.index] + 1
      --local next_character = Public.get_next_character(player.index, current_character)
      --Public.switch_to_character(player, next_character)
    end



  end
end)
--name_tag 


--[[
-- Event handler for when a player crafts an item
script.on_event(defines.events.on_player_crafted_item, function(event)
  local name = event.item_stack.name
  -- Only proceed if the crafted item is "clones-clone"
  if name ~= "clones-clone" then
    return
  end

  local quality = event.item_stack.quality
  local player = game.players[event.player_index]
  -- Ensure the player and their character are valid
  if not (player and player.character and player.character.valid) then
    return
  end

  -- Remove the crafted clone item from the player's inventory
  player.remove_item({ name = name, quality = quality, count = 1 })

  -- Check the crafting queue and refund ingredients if necessary
  local crafting_queue = player.crafting_queue
  if crafting_queue then
    for i = #crafting_queue, 1, -1 do
      local craft = crafting_queue[i]
      if craft.recipe == "clones-clone" then
        local recipe = prototypes.recipe["clones-clone"]
        local ingredients = recipe.ingredients

        -- Cancel crafting and refund the ingredients
        player.cancel_crafting({ index = i, count = craft.count })
        for _, ingredient in pairs(ingredients) do
          player.insert({
            name = ingredient.name,
            count = ingredient.amount * craft.count,
            quality = quality,
          })
        end
      end
    end
  end

  -- Store characters associated with the player
  storage.characters = storage.characters or {}
  storage.characters[player.index] = storage.characters[player.index] or {}

  local current_character = player.character
  local current_character_found = false
  local current_index = 1
  -- Check if the player's current character is already stored
  for i, char in ipairs(storage.characters[player.index]) do
    if char == current_character then
      current_character_found = true
      current_index = i
      break
    end
  end

  -- If not found, add character storage
  if not current_character_found then
    table.insert(storage.characters[player.index], current_character)
    current_index = #storage.characters[player.index]
  end

  -- Find a valid spawn position for the clone
  local pos = player.surface.find_non_colliding_position("character", player.position, 100, 1)
  if pos then
    -- Create the cloned character entity
    local clone = player.surface.create_entity({
      name = player.character.name,
      position = pos,
      force = player.force,
    })

    -- Store the clone and switch to it
    table.insert(storage.characters[player.index], current_index + 1, clone)
    local next_character = Public.get_next_character(player.index, current_character)
    Public.switch_to_character(player, next_character)
  end
end)
]]

-- Event handler for switching characters forward
script.on_event("clones-switch-character-next", function(event)
  local player = game.players[event.player_index]
  storage.characters = storage.characters or {}
  if not (player and player.character and storage.characters[player.index]) then
    return
  end

  local next_character = Public.get_next_character(player.index, player.character)
  Public.switch_to_character(player, next_character)
end)

-- Event handler for switching characters in reverse order
script.on_event("clones-switch-character-previous", function(event)
  local player = game.players[event.player_index]
  storage.characters = storage.characters or {}
  if not (player and player.character and storage.characters[player.index]) then
    return
  end

  local previous_character = Public.get_next_character(player.index, player.character, true)
  Public.switch_to_character(player, previous_character)
end)

-- Event handler for when a player dies
script.on_event(defines.events.on_pre_player_died, function(event)
  local player = game.players[event.player_index]
  local previous_character = Public.get_next_character(player.index, player.character, true)

  -- If a previous character exists, switch to it
  if previous_character then
    Public.switch_to_character(player, previous_character)
  end
end)

-- Event handler for when a player switches controllers
script.on_event(defines.events.on_player_controller_changed, function(event)
  local player = game.players[event.player_index]
  if not (player and player.valid) then
    return
  end

  local controller = player.physical_controller_type
  -- Only proceed if the player is in character mode
  if controller ~= defines.controllers.character then
    return
  end

  local entity = player.character
  if not (entity and entity.valid) then
    return
  end

  -- Ensure the character is stored in the player's character list
  storage.characters = storage.characters or {}
  storage.characters[player.index] = storage.characters[player.index] or {}

  local found = false
  for _, char in ipairs(storage.characters[player.index]) do
    if char == entity then
      found = true
      break
    end
  end

  if not found then
    table.insert(storage.characters[player.index], entity)
  end
end)

--[[-- Prevent clones from entering space via rocket launch
script.on_event(defines.events.on_rocket_launch_ordered, function(event)
  local passenger = event.rocket.get_passenger()
  local passenger = event.player_index 
  if passenger and passenger.name == "character" then
    for _, chars in pairs(storage.characters) do
      for _, char in ipairs(chars) do
        if char == passenger then
          event.rocket.clear_passenger()
          game.players[event.player_index].print("Clones are restricted to this surface and cannot enter space!")
          return
        end
      end
    end
  end
end)
]]

-- Function to retrieve the next or previous character for a player
function Public.get_next_character(player_index, current_character, backwards)
  storage.characters = storage.characters or {}
  local characters = storage.characters[player_index]

  if not characters or #characters == 0 then
    return
  end

  -- Filter valid characters
  local valid_characters = {}
  for _, char in ipairs(characters) do
    if char and char.valid then
      table.insert(valid_characters, char)
    end
  end

  if #valid_characters == 0 then
    return nil
  end

  -- Determine the current index of the character
  local current_index = 1
  for i, char in ipairs(valid_characters) do
    if char == current_character then
      current_index = i
      break
    end
  end

  -- Determine the next or previous character index
  local next_index
  if backwards then
    next_index = ((current_index - 2 + #valid_characters) % #valid_characters) + 1
  else
    next_index = current_index % #valid_characters + 1
  end

  storage.characters[player_index] = valid_characters
  return valid_characters[next_index]
end

-- Function to switch a player to a different character
function Public.switch_to_character(player, target_character)
  if not (player and target_character and target_character.valid) then
    return
  end
  
  local was_previous_character_the_original = player.tag == ""
  if was_previous_character_the_original then
    player.force.add_chart_tag(player.character.surface, {position = player.character.position, text = player.name}) -- icon = {item = "iron-plate"}, 
  end

  -- Temporarily switch to remote/god mode, then switch to the new character
  player.set_controller({ type = defines.controllers.remote })
  player.set_controller({ type = defines.controllers.god })
  player.teleport(target_character.position, target_character.surface)
  player.set_controller({ type = defines.controllers.character, character = target_character })
  if target_character.name_tag then
    player.tag = "(Clone " .. target_character.name_tag .. ")"
  else
    player.tag = ""
    local alltags = player.force.find_chart_tags(player.character.surface)
    if alltags then
      for _, tag in pairs(alltags) do --, {{player.position.x -1, player.position.y -1}, {player.position.x + 1, player.position.y + 1}}
        if tag.text == player.name then
          tag.destroy()
        end
      end
    end
  end


end

return Public
