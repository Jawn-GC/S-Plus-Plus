local sound = require('play_sound')

local volcana2 = {
    identifier = "Volcana-2",
    title = "[Episode C, Level 2] Spicy",
    theme = THEME.VOLCANA,
    world = 3,
	level = 2,
    width = 4,
    height = 4,
    file_name = "Volcana-2.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

volcana2.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	replace_drop(DROP.FACTORY_GENERATOR_SCRAP, ENT_TYPE.MONS_MAGMAMAN)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_SKULL)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function(entity, spawn_flags)
		entity:destroy()
	end, SPAWN_TYPE.ANY, 0, ENT_TYPE.ITEM_PICKUP_SKELETON_KEY)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		entity.flags = set_flag(entity.flags, 6)
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_GENERIC)

	local generators = {}
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
		generators[#generators + 1] = entity
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.FLOOR_FACTORY_GENERATOR)

	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        -- Remove Magmamen.
        local x, y, layer = get_position(entity.uid)
        local lavas = get_entities_at(0, MASK.LAVA, x, y, layer, 1)
        if #lavas > 0 then
            entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
            move_entity(entity.uid, 1000, 0, 0, 0)
        end
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_MAGMAMAN)
	
	level_state.callbacks[#level_state.callbacks+1] = set_post_entity_spawn(function (entity)
        -- Remove Firebugs.
        local x, y, layer = get_position(entity.uid)
        local chains = get_entities_at(0, MASK.ANY, x, y, layer, 1)
        if #chains > 0 then
            entity.flags = set_flag(entity.flags, ENT_FLAG.INVISIBLE)
            move_entity(entity.uid, 1000, 0, 0, 0)
        end
    end, SPAWN_TYPE.ANY, 0, ENT_TYPE.MONS_FIREBUG)
	
	local frames = 0
	local key_collected = false
	local exit_blocks_deactivated = false
	local enemies_dead = {}
	local enemy_uid = {}
	local magma_men_uid = {}
	local belt_left = {}
	local belt_right = {}
	lifebar = 1801 --Number of frames the player has left to live
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()

		if frames == 0 then
			pacifist = true
			no_gold = true
			all_gems = true
			all_gold = true
			genocide = true
			full_health = true
			s_plus_plus = false
			
			for i = 1,#exit_blocks do
				exit_blocks[i]:activate_laserbeam(true)
			end
			
			enemy_uid = get_entities_by_type(ENT_TYPE.MONS_IMP)
			for i = 1,#enemy_uid do
				enemies_dead[i] = false
			end	
			
			for i = 1,#sapphires do
				sapphires[i].x = sapphires[i].x + 0.5
				sapphires[i].y = sapphires[i].y + 0.5
			end

			for i = 1,#key do
				key[i].x = key[i].x + 0.5
			end

			for i = 1,#generators do
				generators[i].timer = 70
				generators[i].set_timer = 120
			end
			
			belt_left = get_entities_by_type(ENT_TYPE.FLOOR_CONVEYORBELT_LEFT)
			belt_right = get_entities_by_type(ENT_TYPE.FLOOR_CONVEYORBELT_RIGHT)
			
			players[1].poison_tick_timer = -1
		end
		
		--Magmamen will face the direction of a conveyor if they are on one.
		--Prevent magmamen from jumping
		magma_men_uid = get_entities_by_type(ENT_TYPE.MONS_MAGMAMAN)
		local magma_man
		for i = 1,#magma_men_uid do
			magma_man = get_entity(magma_men_uid[i])
			magma_man.jump_timer = 2
			for j = 1,#belt_left do
				if magma_man.standing_on_uid == belt_left[j] then
					magma_man.flags = set_flag(magma_man.flags, 17)
				end
			end
			for j = 1,#belt_right do
				if magma_man.standing_on_uid == belt_right[j] then
					magma_man.flags = clr_flag(magma_man.flags, 17)
				end
			end
		end
		
		if #players ~= 0 and lifebar == 0 then
			kill_entity(players[1].uid, false)
		end
		
		for i = 1,#bars do
			if test_flag(bars[i].flags, 29) == true and cashed_gold[i] == false then
				lifebar = lifebar + 60 -- Add a second to remaining time if gold is collected
				cashed_gold[i] = true
			end
		end

		for i = 1,#emeralds do
			if test_flag(emeralds[i].flags, 29) == true and cashed_emeralds[i] == false then
				lifebar = lifebar + 120 -- Add 2 seconds to remaining time if emerald is collected
				cashed_emeralds[i] = true
			end
		end
		
		for i = 1,#sapphires do
			if test_flag(sapphires[i].flags, 29) == true and cashed_sapphires[i] == false then
				lifebar = lifebar + 180 -- Add 3 seconds to remaining time if sapphire is collected
				cashed_sapphires[i] = true
			end
		end
		
		for i = 1,#rubies do
			if test_flag(rubies[i].flags, 29) == true and cashed_rubies[i] == false then
				lifebar = lifebar + 240 -- Add 4 seconds to remaining time if ruby is collected
				cashed_rubies[i] = true
			end
		end

		for i = 1,#diamonds do
			if test_flag(diamonds[i].flags, 29) == true and cashed_diamonds[i] == false then
				lifebar = lifebar + 300 -- Add 5 seconds to remaining time if diamond is collected
				cashed_diamonds[i] = true
			end
		end

		for i = 1,#enemy_uid do
			local ent = get_entity(enemy_uid[i])
			if ent ~= nil and test_flag(ent.flags, 29) == true and enemies_dead[i] == false then
				enemies_dead[i] = true
			end
		end

		if #key ~= 0 and #players ~= 0 and math.sqrt((key[1].x - players[1].x) ^ 2 + (key[1].y - players[1].y) ^ 2 ) < 0.7 and key_collected == false then
			key_collected = true
			key[1].flags = clr_flag(key[1].flags, 28)
			key[1]:destroy()
			sound.play_sound(VANILLA_SOUND.SHARED_DOOR_UNLOCK)
		end
		
		if key_collected == true and exit_blocks_deactivated == false then
			for i = 1,#exit_blocks do
				exit_blocks[i]:activate_laserbeam(false)
			end
			exit_blocks_deactivated = true
		end
		
		if lifebar > 0 and telescope_activated == false and #players ~= 0 and players[1].state ~= CHAR_STATE.ENTERING and players[1].state ~= CHAR_STATE.LOADING then
			lifebar = lifebar - 1
		end
		
		--Check No Gold
		for i = 1,#cashed_gold do
			if cashed_gold[i] == true then
				no_gold = false
			end
		end
		
		--Check All Gold
		if #players ~= 0 and players[1].state == CHAR_STATE.ENTERING then
			for i = 1,#cashed_gold do
				if cashed_gold[i] == false then
					all_gold = false
				end
			end
		end
		
		--Check Pacifist
		for i = 1,#enemy_uid do
			local ent = get_entity(enemy_uid[i])
			if ent ~= nil and enemies_dead[i] == false then
				if #players ~= 0 and (ent.last_owner_uid == players[1].uid or test_flag(state.journal_flags, 1) == false) then
					pacifist = false
				end
			end
		end
		
		--Check Genocide
		if #players ~= 0 and players[1].state == CHAR_STATE.ENTERING then
			for i = 1,#enemies_dead do
				if enemies_dead[i] == false then
					genocide = false
				end
			end
		end
		
		--Check Gems
		if #players ~= 0 and players[1].state == CHAR_STATE.ENTERING then
			for i = 1,#cashed_emeralds do
				if cashed_emeralds[i] == false then
					all_gems = false
				end
			end
			for i = 1,#cashed_sapphires do
				if cashed_sapphires[i] == false then
					all_gems = false
				end
			end
			for i = 1,#cashed_rubies do
				if cashed_rubies[i] == false then
					all_gems = false
				end
			end
			for i = 1,#cashed_diamonds do
				if cashed_diamonds[i] == false then
					all_gems = false
				end
			end
		end

		--Check Health
		if #players ~= 0 and players[1].health < 3 then
			full_health = false
		end

		if #players ~= 0 and players[1].state == CHAR_STATE.ENTERING then
			if (no_gold or all_gold) and (pacifist or genocide) and all_gems and full_health then
				s_plus_plus = true
			end
			
			--Calculate level score
			
			level_score = lifebar * 5
			
			if no_gold then
				level_score = level_score + 5000
			end
			
			if all_gold then
				level_score = level_score + 3000
			end
			
			if pacifist then
				level_score = level_score + 4000
			end
			
			if genocide then
				level_score = level_score + 4000
			end
			
			if all_gems then
				level_score = level_score + 3000
			end

			if full_health then
				level_score = level_score + 2000
			end

			if s_plus_plus then
				level_score = level_score + 10000
			end
			
		end

		frames = frames + 1
		
    end, ON.FRAME)
	
	toast(volcana2.title)
end

volcana2.unload_level = function()
    if not level_state.loaded then return end
   
   	bars = {}
	cashed_gold = {}

	emeralds = {}
	cashed_emeralds = {}
	
	sapphires = {}
	cashed_sapphires = {}
	
	rubies = {}
	cashed_rubies = {}
	
	diamonds = {}
	cashed_diamonds = {}
	
	key = {}
	exit_blocks = {}
	
	state.journal_flags = set_flag(state.journal_flags, 1)
	
	replace_drop(DROP.FACTORY_GENERATOR_SCRAP, ENT_TYPE.ITEM_SCRAP)
   
    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return volcana2