function userscript()
	-- iterator for each player, skips over the caller by checking the current player's ID
	-- (you can also fetch player using global variable CurrCharacterID directly, but referencing player.current() is probably more intuitive)
	local current_player = player.current()
	current_player:displaynameset("Lua Fu Man")

	for p in player.player_iter() do
		if p:id() ~= current_player:id() then
			mugen.log(mugen.gametime() .. " : Killing character " .. p:name() .. " with ID " .. p:id() .. "\n")
			
			-- kill + send to liedown dead state
			p:lifeset(0)
			p:changestate({value = 5150, ctrl = true, selfstate = true}) -- note we pass one table here, effective result is named arguments + function should handle missing/default values
			
			-- retain freeze, set IsHelper to 0, set Alive to 0
			p:ishelperset(0)
			p:isfrozenset(1)
			p:aliveset(0)
		end
	end
end

local status, err = pcall(userscript)
if not status then
	mugen.log("Failed to run user script: " .. err .. "\n")
end