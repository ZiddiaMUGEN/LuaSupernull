function userscript()
	-- iterator for each player, skips over the caller by checking the current player's ID
	-- (you can also fetch player using global variable CurrCharacterID directly, but referencing player.current() is probably more intuitive)
	local current_player = player.current()
	current_player:displaynameset("Kung Fu Man")

	for p in player.player_iter() do
		if p:id() ~= current_player:id() then
			mugen.log(mugen.gametime() .. " : Converting character " .. p:name() .. " with ID " .. p:id() .. " to frozen normal-type helper\n")
			
			-- apply Freeze, set IsHelper to 1, force Normal helper type
			p:ishelperset(1)
			p:isfrozenset(1)
			p:helpertypeset(0)
		end
	end
end

local status, err = pcall(userscript)
if not status then
	mugen.log("Failed to run user script: " .. err .. "\n")
end