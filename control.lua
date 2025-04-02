local Public = {}
--current_global_character 




--local function spawn_clone_with_cloning_machine()

--end

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event) --
  if event.entity and event.entity.name == "cloning-machine" then

    local machine = event.entity
    local player = nil
    --spawn_clone_with_cloning_machine()
    if event.player_index then
      player = game.players[event.player_index]
    elseif machine.last_user then
      player = event.entity.last_user
    end
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
      current_character.name_tag = "clone-original"
    end

    local pos = machine.surface.find_non_colliding_position("character_cloned", {machine.position.x , machine.position.y + 1.5}, 100, 0.3)

    if pos then
      local idx_num = storage.currentclonenumber[player.index]
      local idx = tostring(idx_num)
      local clone = machine.surface.create_entity({
        name = "character_cloned", --player.character.name,
        position = pos,
        force = player.force,
        direction = defines.direction.south,
        move_stuck_players = true,
        create_build_effect_smoke = true,
      })
      clone.name_tag = "(C-" .. idx .. ")" -- C = clone, CV = clone vat
      machine.name_tag = "CV-" .. idx
      player.force.add_chart_tag(machine.surface, {
        position = machine.position, 
        text = machine.name_tag, 
        icon = {type = "virtual", name = "clone_machine"}
      })
      player.force.add_chart_tag(machine.surface, {
        position = pos, 
        text = player.name .. " " .. clone.name_tag, 
        icon = {type = "virtual", name = "clone_character"}
      })
      table.insert(storage.characters[player.index], current_index + 1, clone)
      storage.currentclonenumber[player.index] = storage.currentclonenumber[player.index] + 1
      player.associate_character(clone)
    end
  end
end)
--on entity destroyed: remove entity tag, kill related clone

-- Switching characters with hotkey
script.on_event("clones-switch-character-next", function(event)
  local player = game.players[event.player_index]
  storage.characters = storage.characters or {}
  if not (player and player.character and storage.characters[player.index]) then
    return
  end
  local next_character = Public.get_next_character(player.index, player.character)
  Public.switch_to_character(player, next_character, true)
end)
script.on_event("clones-switch-character-previous", function(event)
  local player = game.players[event.player_index]
  storage.characters = storage.characters or {}
  if not (player and player.character and storage.characters[player.index]) then
    return
  end
  local previous_character = Public.get_next_character(player.index, player.character, true)
  Public.switch_to_character(player, previous_character, true)
end)


-- Event handler for when a player dies
script.on_event(defines.events.on_pre_player_died, function(event)
  local player = game.players[event.player_index]
  if player.character.name_tag then
    if player.character.name == "character_cloned" then
      local previous_character = Public.get_next_character(player.index, player.character, true)
      if previous_character then
        Public.switch_to_character(player, previous_character, false)
      end
    end
  end
end)

-- Event handler for when a building is destroyed
script.on_event(defines.events.on_entity_died, function(event)
  if event.entity then
    if event.entity.name == "cloning-machine" then

      local machine = event.entity
      if machine.name_tag then
        local nametag = machine.name_tag
        string.sub(nametag, 3)
        local maptag = machine.force.find_chart_tags(machine.surface, {{machine.position.x -1, machine.position.y -1}, {machine.position.x + 1, machine.position.y + 1}})
        if maptag then
          for _, tag in pairs(maptag) do
            if tag.text == machine.name_tag then
              tag.destroy()
            end
          end
        end
      end
    elseif event.entity.name == "character_cloned" then
      local clone = event.entity
      --if clone.player then
      --  clone.player.print(clone.player.name)
      --end
      if not clone.player then
        local nametag = clone.name_tag or ""
        local maptag = clone.force.find_chart_tags(clone.surface, {{clone.position.x -1, clone.position.y -1}, {clone.position.x + 1, clone.position.y + 1}})
        if maptag then
          for _, tag in pairs(maptag) do
            if string.find(tag.text, nametag) then
              tag.destroy()
            end
          end
        end
        local player = nil
        if clone.last_user then
          player = clone.last_user
        elseif clone.associated_player then
          player = clone.associated_player
        end

        if player then
          player.print(player.name .. " " .. nametag .. " has died")
        end
      end
    end
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
function Public.switch_to_character(player, target_character, add_tag_to_previous)
  if not (player and target_character and target_character.valid) then
    return
  end

  if add_tag_to_previous then
    if player.tag and player.tag ~= "" and player.tag ~= "clone-original" and player.character.name_tag then
      player.force.add_chart_tag(player.character.surface, {
        position = player.character.position, 
        text = player.name .. " " .. player.character.name_tag, 
        icon = {type = "virtual", name = "clone_character"}
      })
    else
      player.force.add_chart_tag(player.character.surface, {
        position = player.character.position, 
        text = player.name, 
        icon = {type = "virtual", name = "mainplayer_character"}
      })
    end
  end

  -- Temporarily switch to remote/god mode, then switch to the new character
  player.set_controller({ type = defines.controllers.remote })
  player.set_controller({ type = defines.controllers.god })
  player.teleport(target_character.position, target_character.surface)
  player.set_controller({ type = defines.controllers.character, character = target_character })

  -- Handle player name and map tag removal
  local maptag = player.force.find_chart_tags(player.character.surface, {{player.position.x -1, player.position.y -1}, {player.position.x + 1, player.position.y + 1}})
  if target_character.name_tag then
    if target_character.name == "character_cloned" then
      player.tag = target_character.name_tag
      if maptag then
        for _, tag in pairs(maptag) do
          if tag.text == player.name .. " " .. player.character.name_tag then
            tag.destroy()
          end
        end
      end
    else
      player.tag = ""
      if maptag then
        for _, tag in pairs(maptag) do
          if tag.text == player.name then
            tag.destroy()
          end
        end
      end
    end
  end


end

return Public
