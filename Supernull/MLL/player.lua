-- This is a table-based wrapper for the default `player` userdata provided by MUGEN.
-- The intention is to provide a bunch of functions which can be used to supplement regular MUGEN code.
-- There may or may not be a better way to do this, I'm not great with Lua but I couldn't add new functions to the userdata (at least not with the self-based syntax)

-- handle weirdness in 1.1b1 not loading player module properly
-- the key difference is 1.1b1 uses `require` and 1.1a4 uses `dofile`, `require` has some sort of lazy load it seems?
if player.interface_functions == nil then
	pwd = io.popen("cd"):read('*l') .. "/data" -- https://stackoverflow.com/a/6036884 - the sketch
	dofile(pwd .. "/mugen.lua")
	dofile(pwd .. "/player.lua")
end

-- retain a reference to original player module as player_
-- do a quick check here to make sure we don't trash the backing player_ on second load
if _G.player_ == nil then
	local p = player
	_G.player_ = p
end
 
-- BEGIN PLAYER MODULE WRAPPER
	local player = { }
	player.__index = player

	-- constructor, wrap the userdata p_
	function player:new(p_)
		p = { }
		setmetatable(p, self)
		
		p.wrapped = p_
		-- since a given player's address will never change for the lifetime of MUGEN (probably...) it's slightly more efficient to read once and stash it for a player object
		p.address = mll.ReadInteger(mugen.getbaseaddress() + 0x12274 + player.indexfromid(p:id()) * 4)
		return p
	end

	--- below are some wrapper functions for functions in player.lua.
	function player.player_iter()
		local i = 0
		local idxlist = player_.getplayerlist()
		local n = #idxlist
		return function ()
			local p = nil
			while i < n and not p do
				i = i + 1
				local idx = idxlist[i]
				p = player_.getplayer(idx)
				if p then return player:new(p) end
			end
		end
	end

	function player.interface_iter()
		local i = 0
		local idxlist = player_.getplayerlist()
		local n = #idxlist
		return function ()
			local interface = nil
			while i < n and not interface do
				i = i + 1
				local idx = idxlist[i]
				interface = player_.getinterface(idx)
				if interface then return interface; end
			end
		end
	end

	-- these are almost irrelevant since we don't use sandboxed calls anyway
	player.interface_functions = player_.interface_functions
	player.interface_functions_sig = player_.interface_functions_sig
	player.interface_functions_vector_retval = player_.interface_functions_vector_retval

	function player.getplayer(idx) return player:new(player_.getplayer(idx)) end
	function player.getinterface(idx) return player_.getinterface(idx) end
	function player.getplayerlist() return player_.getplayerlist() end
	function player.playeridexist(id) return player_.playeridexist(id) end
	function player.indexfromid(id) return player_.indexfromid(id) end
	function player.indexisvalid(id) return player_.indexisvalid(id) end
	function player.enabled(idx) return player_.enabled(idx) end
	function player.enableset(idx, b) return player_.enableset(idx, b) end

	--- auto-wrap the getter functions since they're simple to wrap
	for _,func in pairs(player.interface_functions) do
		player[func] = function(self) return self.wrapped[func](self.wrapped) end
	end

	-- re-wrap functions which take arguments and/or don't return, since auto-wrap with a return produces garbage for that
	function player:animelemno(t) return self.wrapped:animelemno(t) end
	function player:animelemtime(t) return self.wrapped:animelemtime(t) end
	function player:animexist(animno) return self.wrapped:animexist(animno) end
	function player:selfanimexist(animno) return self.wrapped:selfanimexist(animno) end
	function player:projcanceltime(idx) return self.wrapped:projcanceltime(idx) end
	function player:projhittime(idx) return self.wrapped:projhittime(idx) end
	function player:projguardedtime(idx) return self.wrapped:projguardedtime(idx) end
	function player:projcontacttime(idx) return self.wrapped:projcontacttime(idx) end
	function player:lifeset(value) self.wrapped:lifeset(value) end
	function player:powerset(value) self.wrapped:powerset(value) end
	function player:aienableset(value) self.wrapped:aienableset(value) end
	function player:numhelper(id) return self.wrapped:numhelper(id) end
	function player:numexplod(id) return self.wrapped:numexplod(id) end
	function player:var(idx) return self.wrapped:var(idx) end
	function player:fvar(idx) return self.wrapped:fvar(idx) end
	function player:sysvar(idx) return self.wrapped:sysvar(idx) end
	function player:sysfvar(idx) return self.wrapped:sysfvar(idx) end
	function player:warning(s) self.wrapped:warning(s) end
	function player:error(s) self.wrapped:error(s) end

	-- functions i haven't figured out the signature for
	function player:hitdefattrmatch() return false end

	-- sctrl functions replicated from base, just pass the table through without validation (the base function hopefully validates...)
	function player:velset(tab) self.wrapped:velset(tab) end
	function player:explod(tab) self.wrapped:explod(tab) end
	function player:changestate(tab) self.wrapped:changestate(tab) end
	
	-- vector returns
	function player:vel() return self.wrapped:vel() end
	function player:pos() return self.wrapped:pos() end
	function player:screenpos() return self.wrapped:screenpos() end
	function player:backedge() return self.wrapped:backedge() end
	function player:frontedge() return self.wrapped:frontedge() end
	function player:frontedgedist() return self.wrapped:frontedgedist() end
	function player:backedgedist() return self.wrapped:backedgedist() end
	function player:frontedgebodydist() return self.wrapped:frontedgebodydist() end
	function player:backedgebodydist() return self.wrapped:backedgebodydist() end
	function player:hitvel() return self.wrapped:hitvel() end
	function player:parentdist() return self.wrapped:parentdist() end
	function player:rootdist() return self.wrapped:rootdist() end
	function player:const(name) return self.wrapped:const(name) end
	function player:gethitvar(name) return self.wrapped:gethitvar(name) end

-- END PLAYER MODULE WRAPPER

-- BEGIN PLAYER MODULE NEW FUNCTIONALITY
	-- utility on module
	function player.playerfromid(id) return player.getplayer(player.indexfromid(id)) end
	function player.current() return player.playerfromid(CurrCharacterID) end
	
	-- utility on object
	function player:getplayeraddress() return self.address end
	function player:getinfoaddress() return mll.ReadInteger(self.address) end

	-- state controllers and pseudo-state controllers
	function player:ctrlset(tab) 
		if tab.value ~= nil then mll.WriteInteger(self:getplayeraddress() + 0xEE4, tab.value) end
	end

	function player:varset(idx, value)
		if idx < 0 or idx > 59 then return end
		mll.WriteInteger(self:getplayeraddress() + 0xF1C + idx * 4, value)
	end

	function player:fvarset(idx, value) 
		if idx < 0 or idx > 39 then return end
		mll.WriteFloat(self:getplayeraddress() + 0x100C + idx * 4, value)
	end

	function player:sysvarset(idx, value) 
		if idx < 0 or idx > 4 then return end
		mll.WriteInteger(self:getplayeraddress() + 0x10AC + idx * 4, value)
	end

	function player:sysfvarset(idx, value) 
		if idx < 0 or idx > 4 then return end
		mll.WriteFloat(self:getplayeraddress() + 0x10C0 + idx * 4, value)
	end


	
	-- getters
	function player:displayname() return mll.ReadString(self:getinfoaddress() + 0x30) end
	function player:isfrozen() return mll.ReadInteger(self:getplayeraddress() + 0x1B4) end
	function player:guardflag() return mll.ReadInteger(self:getplayeraddress() + 0xEE8) end
	function player:helperid() return mll.ReadInteger(self:getplayeraddress() + 0x1644) end
	function player:parentid() return mll.ReadInteger(self:getplayeraddress() + 0x1648) end
	function player:helpertype() return mll.ReadInteger(self:getplayeraddress() + 0x1654) end

	-- setters
	function player:nameset(value) mll.WriteString(self:getinfoaddress() + 0x00, value) end
	function player:displaynameset(value) mll.WriteString(self:getinfoaddress() + 0x30, value) end
	function player:authornameset(value) mll.WriteString(self:getinfoaddress() + 0x60, value) end
	function player:idset(value) mll.WriteInteger(self:getplayeraddress() + 0x04, value) end
	function player:teamsideset(value) mll.WriteInteger(self:getplayeraddress() + 0x0C, value) end
	function player:ishelperset(value) mll.WriteInteger(self:getplayeraddress() + 0x1C, value) end
	function player:isfrozenset(value) mll.WriteInteger(self:getplayeraddress() + 0x1B4, value) end
	function player:lifemaxset(value) 
		if value == 0 then mugen.log("Refusing to set LifeMax to 0 - this will crash your game.\n") end
		mll.WriteInteger(self:getplayeraddress() + 0x1BC, value) 
	end
	function player:powermaxset(value) 
		if value == 0 then mugen.log("Refusing to set PowerMax to 0 - this will crash your game?\n") end
		mll.WriteInteger(self:getplayeraddress() + 0x1DC, value) 
	end
	function player:statenoset(value) mll.WriteInteger(self:getplayeraddress() + 0xCCC, value) end
	function player:prevstatenoset(value) mll.WriteInteger(self:getplayeraddress() + 0xCD0, value) end
	function player:timeset(value) mll.WriteInteger(self:getplayeraddress() + 0xED4, value) end
	function player:guardflagset(value) mll.WriteInteger(self:getplayeraddress() + 0xEE8, value) end
	function player:hitpausetimeset(value) mll.WriteInteger(self:getplayeraddress() + 0xEF0, value) end
	function player:aliveset(value) mll.WriteInteger(self:getplayeraddress() + 0xF00, value) end
	function player:hitcountset(value) mll.WriteInteger(self:getplayeraddress() + 0x1520, value) end
	function player:uniqhitcountset(value) mll.WriteInteger(self:getplayeraddress() + 0x1524, value) end
	function player:palnoset(value) mll.WriteInteger(self:getplayeraddress() + 0x153C, value) end
	function player:helperidset(value) mll.WriteInteger(self:getplayeraddress() + 0x1644, value) end
	function player:parentidset(value) mll.WriteInteger(self:getplayeraddress() + 0x1648, value) end
	function player:helpertypeset(value) mll.WriteInteger(self:getplayeraddress() + 0x1654, value) end
	function player:ailevelset(value) mll.WriteInteger(self:getplayeraddress() + 0x1658, value) end
-- END PLAYER MODULE NEW FUNCTIONALITY

-- update the player module
_G.player = player