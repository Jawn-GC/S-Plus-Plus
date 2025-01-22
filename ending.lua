local ending = {
    identifier = "Ending",
    title = "Ending",
    theme = THEME.CITY_OF_GOLD,
    world = 6,
	level = 1,
    width = 4,
    height = 6,
    file_name = "CoG.lvl",
}

local level_state = {
    loaded = false,
    callbacks = {},
}

ending.load_level = function()
    if level_state.loaded then return end
    level_state.loaded = true
	
	local frames = 0
	level_state.callbacks[#level_state.callbacks+1] = set_callback(function ()
		players[1]:set_cursed(false)
	
		if frames == 0 then
			pacifist = true
			no_gold = true
			all_gems = true
			all_gold = true
			genocide = true
			full_health = true
			s_plus_plus = false
			
			lifebar = 0
		
			players[1].inventory.bombs = 10
		end
	
        frames = frames + 1
    end, ON.FRAME)
	
	toast("The End")
end

ending.unload_level = function()
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

    local callbacks_to_clear = level_state.callbacks
    level_state.loaded = false
    level_state.callbacks = {}
    for _, callback in pairs(callbacks_to_clear) do
        clear_callback(callback)
    end
end

return ending