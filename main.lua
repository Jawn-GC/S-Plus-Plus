meta = {
    name = 'S++',
    version = '2.0',
    description = 'Levels inspired by N++',
    author = 'JawnGC',
}

register_option_int("level_selected", "Level number for shortcut door (1 to 25)", 1, 1, 25)
register_option_bool("speedrun_mode", "Instant Restart on death", false)

local level_sequence = require("LevelSequence/level_sequence")
local DIFFICULTY = require('difficulty')
local telescopes = require("Telescopes/telescopes")
local SIGN_TYPE = level_sequence.SIGN_TYPE
local save_state = require('save_state')
local horizontal_forcefields = require('horizontal_forcefields')
local olmec_pillars = require('olmec_pillars')
local blockchain_and_firebug = require("blockchain_and_firebug")

local update_continue_door_enabledness
local force_save
local save_data
local save_context

--Episode A
local dwelling1 = require("dwelling1")
local volcana1 = require("volcana1")
local temple1 = require("temple1")
local neobabylon1 = require("neobabylon1")
local sunkencity1 = require("sunkencity1")

--Episode B
local dwelling2 = require("dwelling2")
local jungle1 = require("jungle1")
local tidepool1 = require("tidepool1")
local neobabylon2 = require("neobabylon2")
local sunkencity2 = require("sunkencity2")

--Episode C
local dwelling3 = require("dwelling3")
local volcana2  = require("volcana2")
local jungle2 = require("jungle2")
local tidepool2 = require("tidepool2")
local temple2 = require("temple2")

--Episode D
local volcana3 = require("volcana3")
local jungle3 = require("jungle3")
local tidepool3 = require("tidepool3")
local temple3 = require("temple3")
local sunkencity3 = require("sunkencity3")

--Episode E
local neobabylon3 = require("neobabylon3")
local dwelling4 = require("dwelling4")
local tidepool4 = require("tidepool4")
local volcana4 = require("volcana4")
local temple4 = require("temple4")

--Ending Level
local ending = require("ending")

--Set level order
levels = {dwelling1, volcana1, temple1, neobabylon1, sunkencity1, dwelling2, jungle1, tidepool1, neobabylon2, sunkencity2, dwelling3, volcana2, jungle2, tidepool2, temple2, volcana3, jungle3, tidepool3, temple3, sunkencity3, neobabylon3, dwelling4, tidepool4, volcana4, temple4, ending}
level_sequence.set_levels(levels)

--Do not spawn Ghost
set_time_ghost_enabled(false)

--Remove powerups, drop items
set_post_entity_spawn(function(entity) 
	entity.flags = clr_flag(entity.flags, 22) 
end, SPAWN_TYPE.ANY, MASK.ITEM, nil)

set_callback(function()
    if state.loading == 1 and state.screen_next == SCREEN.TRANSITION then
        for _, p in ipairs(players) do
            for _, v in ipairs(p:get_powerups()) do
                p:remove_powerup(v)
            end
        end
    end
end, ON.LOADING)

--Gold Bars
bars = {}
cashed_gold = {}
define_tile_code("floating_gold_bar")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_GOLDBAR, x, y, layer, 0, 0)
	bars[#bars + 1] = get_entity(block_id)
	bars[#bars].flags = set_flag(bars[#bars].flags, 10)
	bars[#bars].flags = clr_flag(bars[#bars].flags, 13)
	cashed_gold[#cashed_gold + 1] = false
	return true
end, "floating_gold_bar")

--Emeralds
emeralds = {}
cashed_emeralds = {}
define_tile_code("floating_emerald")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_EMERALD, x, y, layer, 0, 0)
	emeralds[#emeralds + 1] = get_entity(block_id)
	emeralds[#emeralds].flags = set_flag(emeralds[#emeralds].flags, 10)
	emeralds[#emeralds].flags = clr_flag(emeralds[#emeralds].flags, 13)
	cashed_emeralds[#cashed_emeralds + 1] = false
	return true
end, "floating_emerald")

--Sapphires
sapphires = {}
cashed_sapphires = {}
define_tile_code("floating_sapphire")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_SAPPHIRE, x, y, layer, 0, 0)
	sapphires[#sapphires + 1] = get_entity(block_id)
	sapphires[#sapphires].flags = set_flag(sapphires[#sapphires].flags, 10)
	sapphires[#sapphires].flags = clr_flag(sapphires[#sapphires].flags, 13)
	cashed_sapphires[#cashed_sapphires + 1] = false
	return true
end, "floating_sapphire")

--Rubies
rubies = {}
cashed_rubies = {}
define_tile_code("floating_ruby")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_RUBY, x, y, layer, 0, 0)
	rubies[#rubies + 1] = get_entity(block_id)
	rubies[#rubies].flags = set_flag(rubies[#rubies].flags, 10)
	rubies[#rubies].flags = clr_flag(rubies[#rubies].flags, 13)
	cashed_rubies[#cashed_rubies + 1] = false
	return true
end, "floating_ruby")

--Diamonds
diamonds = {}
cashed_diamonds = {}
define_tile_code("floating_diamond")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_DIAMOND, x, y, layer, 0, 0)
	diamonds[#diamonds + 1] = get_entity(block_id)
	diamonds[#diamonds].flags = set_flag(diamonds[#diamonds].flags, 10)
	diamonds[#diamonds].flags = clr_flag(diamonds[#diamonds].flags, 13)
	cashed_diamonds[#cashed_diamonds + 1] = false
	return true
end, "floating_diamond")

--Exit Blocks
exit_blocks = {}
define_tile_code("exit_block")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.FLOOR_FORCEFIELD, x, y, layer, 0, 0)
	exit_blocks[#exit_blocks + 1] = get_entity(block_id)
	return true
end, "exit_block")

--Exit Key
key = {}
define_tile_code("exit_key")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn(ENT_TYPE.ITEM_KEY, x, y, layer, 0 , 0)
	key[#key + 1] = get_entity(block_id)
	key[#key].flags = set_flag(key[#key].flags, 28)
end, "exit_key")

--Mushrooms
define_tile_code("shroom")
set_pre_tile_code_callback(function(x, y, layer)
	spawn_mushroom(x, y, layer, 4)
	return true
end, "shroom")

--Quillback who rolls forever after seen the player
define_tile_code("infinite_quillback")
set_pre_tile_code_callback(function(x, y, layer)
    local quill = spawn(ENT_TYPE.MONS_CAVEMAN_BOSS, x, y, layer, 0, 0)
    set_post_statemachine(quill, function(ent)
        if ent.seen_player then
            ent.move_state = 10
        end
    end)
    return true
end, "infinite_quillback")

--Climbing Gloves
define_tile_code("climbers")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_PICKUP_CLIMBINGGLOVES, x, y, layer, 0, 0)		
	return true
end, "climbers")

--Machete
define_tile_code("danny_trejo")
set_pre_tile_code_callback(function(x, y, layer)
	local block_id = spawn_entity_snapped_to_floor(ENT_TYPE.ITEM_MACHETE, x, y, layer, 0, 0)		
	return true
end, "danny_trejo")

local create_stats = require('stats')
local function create_saved_run()
	return {
		has_saved_run = false,
		saved_run_attempts = nil,
		saved_run_time = nil,
		saved_run_level = nil,
	}
end

local game_state = {
	difficulty = DIFFICULTY.NORMAL,
	stats = create_stats(),
	normal_saved_run = create_saved_run(),
}

local continue_door

function update_continue_door_enabledness()
	if not continue_door then return end
	local current_saved_run = game_state.normal_saved_run
	continue_door.update_door(current_saved_run.saved_run_level, current_saved_run.saved_run_attempts, current_saved_run.saved_run_time)
end

-- "Continue Run" Door
define_tile_code("continue_run")
local function continue_run_callback()
	return set_pre_tile_code_callback(function(x, y, layer)
		continue_door = level_sequence.spawn_continue_door(
			x,
			y,
			layer,
			game_state.normal_saved_run.saved_run_level,
			game_state.normal_saved_run.saved_run_attempts,
			game_state.normal_saved_run.saved_run_time,
			SIGN_TYPE.RIGHT)
		return true
	end, "continue_run")
end

-- Creates a door for the shortcut, uses "volcana_shortcut" tile code
define_tile_code("volcana_shortcut")
local function shortcut_callback()
	return set_pre_tile_code_callback(function(x, y, layer)
	
		if options.level_selected < 1 then
			options.level_selected = 1
		elseif options.level_selected > #levels - 1 then
			options.level_selected = #levels - 1
		end
		
		level_sequence.spawn_shortcut(x, y, layer, levels[options.level_selected], SIGN_TYPE.RIGHT)
		return true
	end, "volcana_shortcut")
end

level_sequence.set_on_win(function(attempts, total_time)
	warp(1, 1, THEME.BASE_CAMP)
end)

--Display Time Remaining, Score, and Challenges Completed
lifebar = 0

pacifist = true
no_gold = true
all_gems = true
all_gold = true
genocide = true
full_health = true
s_plus_plus = false

level_score = 0

local red = 245
local green = 39
local blue = 39
set_callback(function(ctx)
    local _, size = get_window_size()
    size = size / 20
	
	local seconds
	local milli
	local remainder
	
	seconds = lifebar // 60
	remainder = lifebar - (seconds * 60)
	
	milli = math.floor(remainder * 16.667) / 1000.0
	
	local no_gold_challenge = ''
	local all_gold_challenge = ''
	local pacifist_challenge = ''
	local gems_challenge = ''
	local genocide_challenge = ''
	local full_health_challenge = ''
	local s_plus_plus_challenge = ''
	
	if no_gold == true then
		no_gold_challenge = ', G--'
	end
	
	if all_gold == true then
		all_gold_challenge = ', G++'
	end
	
	if pacifist == true then
		pacifist_challenge = ', P++'
	end
	
	if genocide == true then
		genocide_challenge = ', P--'
	end
	
	if all_gems == true then
		gems_challenge = ', T++'
	end
	
	if full_health == true then
		full_health_challenge = ', D--'
	end
	
	if s_plus_plus == true then
		s_plus_plus_challenge = ', S++'
	end
	
	if red == 245 and green < 245 and blue == 39 then
		green = green + 2
	elseif red > 39 and green == 245 and blue == 39 then
		red = red - 2
	elseif red == 39 and green == 245 and blue < 245 then
		blue = blue + 2
	elseif red == 39 and green > 39 and blue == 245 then
		green = green - 2
	elseif red < 245 and green == 39 and blue == 245 then
		red = red + 2
	elseif red == 245 and green == 39 and blue > 39 then
		blue = blue - 2
	end
	
	if state.screen == ON.LEVEL and level_sequence.get_run_state().current_level.identifier ~= "Ending" then
		local text = 'Time Remaining: ' .. string.format("%.3f", seconds + milli)
		local w, h = draw_text_size(size, text)
		ctx:draw_text(0-w/2, -0.9-h/2, size, text, rgba(255, 255, 255, 255))
	elseif state.screen == ON.LEVEL and level_sequence.get_run_state().current_level.identifier == "Ending" then
		local text = ''
		local w, h = draw_text_size(size, text)
		ctx:draw_text(0-w/2, -0.9-h/2, size, text, rgba(255, 255, 255, 255))
	elseif state.screen == ON.TRANSITION and s_plus_plus == true then
		local text = 'Score: ' .. tostring(level_score) .. no_gold_challenge .. all_gold_challenge .. pacifist_challenge .. genocide_challenge .. gems_challenge .. full_health_challenge .. s_plus_plus_challenge
		local w, h = draw_text_size(size, text)
		ctx:draw_text(0-w/2, -0.9-h/2, size, text, rgba(red, green, blue, 255)) -- Rainbow Text for S++
	elseif state.screen == ON.TRANSITION then
		local text = 'Score: ' .. tostring(level_score) .. no_gold_challenge .. all_gold_challenge .. pacifist_challenge .. genocide_challenge .. gems_challenge .. full_health_challenge
		local w, h = draw_text_size(size, text)
		ctx:draw_text(0-w/2, -0.9-h/2, size, text, rgba(255, 255, 255, 255))
	end
end, ON.GUIFRAME)

--Dark Level stuff
set_callback(function()
	if state.theme == THEME.BASE_CAMP then
		state.level_flags = clr_flag(state.level_flags, 18)
	elseif level_sequence.get_run_state().current_level.identifier == "Temple-4" then
		state.level_flags = set_flag(state.level_flags, 18)
	else	
		state.level_flags = clr_flag(state.level_flags, 18)
	end	
end, ON.POST_ROOM_GENERATION)

set_callback(function()
    if state.loading == 1 and state.screen_next == SCREEN.TRANSITION then
        for _, p in ipairs(players) do
            for _, v in ipairs(p:get_powerups()) do
                p:remove_powerup(v)
            end
        end
    end
end, ON.LOADING)

--Remove resources from the player and set health to 3
--Remove held item from the player
level_sequence.set_on_post_level_generation(function(level)
	if #players == 0 then return end
	
	players[1].inventory.bombs = 0
	players[1].inventory.ropes = 0
	players[1].health = 3
	
	if players[1].holding_uid ~= -1 then
		players[1]:get_held_entity():destroy()
	end
end)

level_sequence.set_on_completed_level(function(completed_level, next_level)
	if not next_level then return end

	local current_stats = game_state.stats
	local best_level_index = level_sequence.index_of_level(current_stats.best_level)
	local current_level_index = level_sequence.index_of_level(next_level)

	if (not best_level_index or current_level_index > best_level_index) and
			not level_sequence.took_shortcut() then
				current_stats.best_level = next_level
	end
end)

-- Manage saving data and keeping the time in sync during level transitions and resets.
function save_data()
	if save_context then
		force_save(save_context)
	end
end

function save_current_run_stats()
	local run_state = level_sequence.get_run_state()
	-- Save the current run
	if state.theme ~= THEME.BASE_CAMP and
		level_sequence.run_in_progress() then
		local saved_run = game_state.normal_saved_run
		saved_run.saved_run_attempts = run_state.attempts
		saved_run.saved_run_level = run_state.current_level
		saved_run.saved_run_time = run_state.total_time
		saved_run.has_saved_run = true
	end
end

function save_current_run_stats2()
	local run_state = level_sequence.get_run_state()
	-- Save the current run
	if state.theme ~= THEME.BASE_CAMP and
		level_sequence.run_in_progress() then
		local saved_run = game_state.normal_saved_run
		saved_run.saved_run_level = run_state.current_level
		saved_run.has_saved_run = true
	end
end

-- Saves the current state of the run so that it can be continued later if exited.
local function save_current_run_stats_callback()
	return set_callback(function()
		save_current_run_stats()
	end, ON.FRAME)
end

local function save_current_run_stats_callback2()
	return set_callback(function()
		save_current_run_stats2()
	end, ON.TRANSITION)
end

local function clear_variables_callback()
	return set_callback(function()
		continue_door = nil
	end, ON.PRE_LOAD_LEVEL_FILES)
end

set_callback(function(ctx)
	game_state = save_state.load(game_state, level_sequence, ctx)
end, ON.LOAD)

function force_save(ctx)
	save_state.save(game_state, level_sequence, ctx)
end

local function on_save_callback()
	return set_callback(function(ctx)
		save_context = ctx
		force_save(ctx)
	end, ON.SAVE)
end

local active = false
local callbacks = {}

local function activate()
	if active then return end
	active = true
	level_sequence.activate()

	local function add_callback(callback_id)
		callbacks[#callbacks+1] = callback_id
	end

	add_callback(continue_run_callback())
	add_callback(shortcut_callback())
	add_callback(clear_variables_callback())
	add_callback(on_save_callback())
	add_callback(save_current_run_stats_callback())
	add_callback(save_current_run_stats_callback2())
end

set_callback(function()
    activate()
end, ON.LOAD)

set_callback(function()
    activate()
end, ON.SCRIPT_ENABLE)

set_callback(function()
    if not active then return end
	active = false
	level_sequence.deactivate()

	for _, callback in pairs(callbacks) do
		clear_callback(callback)
	end

	callbacks = {}

end, ON.SCRIPT_DISABLE)

--Instant Restart on death
set_callback(function()
	if options.speedrun_mode then
		if state.screen ~= 12 then
			return
		end

		local health = 0
		for i = 1,#players do
			health = health + players[i].health
		end

		if health == 0 then
			state.quest_flags = set_flag(state.quest_flags, 1)
			warp(state.world_start, state.level_start, state.theme_start)
		end
	end
end, ON.FRAME)