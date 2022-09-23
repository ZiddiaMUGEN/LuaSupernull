-- Extension module for the mugen module.
-- Unlike player.lua, this just extends the existing functionality of the mugen module, rather than wrapping it.
-- This is because mugen module doesn't expose userdata objects, so it's easy to add new methods which are immediately available.

-- BEGIN MUGEN MODULE NEW FUNCTIONALITY
function mugen.getbaseaddress()
	return mll.ReadInteger(0x5040E8)
end

function mugen.explodmax() return mll.ReadInteger(mugen.getbaseaddress() + 0x12944) end
function mugen.helpermax() return mll.ReadInteger(mugen.getbaseaddress() + 0x12168) end
function mugen.helperexist()
	local count = 0
	for p in player.player_iter() do
		if p:ishelper() then count = count + 1 end
	end
	return count
end

function mugen.gametimeset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x11E98, value) end
function mugen.roundnoset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x12728, value) end
function mugen.roundstateset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x12754, value) end
function mugen.matchnoset(value) mll.WriteInteger(mugen.getbaseaddress() + 0x12824, value) end

function mugen.winset(value, wintype, winperfect)
	-- possible wintype values: 0 = win by normal, 1 = win by special, 2 = win by hyper, 3 = win by cheese, 4 = timeup, 5 = win by throw, 6 = win by suicide, 7 = killed by teammate
	-- invalid teams
	if value ~= 1 and value ~= 2 then return end
	-- default wintype
	if wintype == nil then wintype = 0 end
	-- default winperfect
	if winperfect == nil then winperfect = false end
	winperfect = int2bool(winperfect)

	-- write winning team
	mll.WriteInteger(mugen.getbaseaddress() + 0x12758, value)
	mll.WriteInteger(mugen.getbaseaddress() + 0x1275C, 1)

	-- update wintype for rendering
	mugen.wintypeset(mugen.wincount(value) + 1, value, wintype)
	-- update winperfect for rendering
	mugen.winperfectset(mugen.wincount(value) + 1, value, winperfect)
end

function mugen.wintypeset(round, team, value)
	if round < 1 or round > 10 then return end
	-- determine offset based on team and round input
	local offset = mugen.getbaseaddress() + 0x12778 + (round - 1) * 4
	if team == 2 then
		offset = offset + 0x28
	end

	mll.WriteInteger(offset, value)
end

function mugen.winperfectset(round, team, value)
	if round < 1 or round > 10 then return end
	-- determine offset based on team and round input
	local offset = mugen.getbaseaddress() + 0x127C8 + (round - 1) * 4
	if team == 2 then
		offset = offset + 0x28
	end
	value = int2bool(value)
	-- set rendering winperfect
	if value then
		mll.WriteInteger(offset, 0x08)
	else
		mll.WriteInteger(offset, -1)
	end
end

function mugen.isassertintro() return mll.ReadByte(mugen.getbaseaddress() + 0x1269C) end
function mugen.isassertroundnotover() return mll.ReadByte(mugen.getbaseaddress() + 0x1269D) end
function mugen.isassertnoko() return mll.ReadByte(mugen.getbaseaddress() + 0x1269E) end
function mugen.isassertnokosnd() return mll.ReadByte(mugen.getbaseaddress() + 0x1269F) end
function mugen.isassertnokoslow() return mll.ReadByte(mugen.getbaseaddress() + 0x126A0) end
function mugen.isassertnomusic() return mll.ReadByte(mugen.getbaseaddress() + 0x126A1) end
function mugen.isassertglobalnoshadow() return mll.ReadByte(mugen.getbaseaddress() + 0x126A2) end
function mugen.isasserttimerfreeze() return mll.ReadByte(mugen.getbaseaddress() + 0x126A3) end
function mugen.isassertnobardisplay() return mll.ReadByte(mugen.getbaseaddress() + 0x126A4) end
function mugen.isassertnobg() return mll.ReadByte(mugen.getbaseaddress() + 0x126A5) end
function mugen.isassertnofg() return mll.ReadByte(mugen.getbaseaddress() + 0x126A6) end

function mugen.stagename() return mll.ReadString(mugen.getbaseaddress() + 0x1AE4) end
function mugen.stagedisplayname() return mll.ReadString(mugen.getbaseaddress() + 0x1B14) end
function mugen.stageauthorname() return mll.ReadString(mugen.getbaseaddress() + 0x1B44) end
function mugen.stagefile() return mll.ReadString(mugen.getbaseaddress() + 0x1B74) end

function mugen.wincount(team) return mll.ReadInteger(mugen.getbaseaddress() + 0x12728 + 4 * team) end
-- END MUGEN MODULE NEW FUNCTIONALITY