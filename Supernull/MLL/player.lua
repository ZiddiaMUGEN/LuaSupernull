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

-- https://stackoverflow.com/a/32389020
OR, XOR, AND = 1, 3, 4
function bitoper(a, b, oper)
	local r, m, s = 0, 2^31
	repeat
	   s,a,b = a+b+m, a%m, b%m
	   r,m = r + m*oper%(s-a-b), m/2
	until m < 1
	return r
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
	function player.enableset(idx, b) 
		b = int2bool(b)
		return player_.enableset(idx, b) 
	end

	--- auto-wrap the getter functions since they're simple to wrap
	for _,func in pairs(player.interface_functions) do
		player[func] = function(self) return self.wrapped[func](self.wrapped) end
	end

	-- re-wrap functions which take arguments and/or don't return, since auto-wrap with a return produces garbage for that
	function player:animno() return self.wrapped:anim() end
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
	function player:aienableset(value) 
		value = int2bool(value)
		self.wrapped:aienableset(value) 
	end
	function player:numhelper(id) return self.wrapped:numhelper(id) end
	function player:numexplod(id) 
		if id == nil then id = -1 end
		return self.wrapped:numexplod(id) 
	end
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
	function player:explod(tab)
		-- fixup boolean inputs
		if tab.usefightfx ~= nil then tab.usefightfx = int2bool(tab.usefightfx) end
		if tab.ownpal ~= nil then tab.ownpal = int2bool(tab.ownpal) end
		if tab.shadow ~= nil then tab.shadow = int2bool(tab.shadow) end
		if tab.removeongethit ~= nil then tab.removeongethit = int2bool(tab.removeongethit) end
		if tab.hitpausemove ~= nil then tab.hitpausemove = int2bool(tab.hitpausemove) end
		-- fixup non-Vector inputs to Vector
		if tab.pos ~= nil and getmetatable(tab.pos) ~= Vector then
			tab.pos = Vector:vec2(tab.pos.x or 0, tab.pos.y or 0)
		end
		if tab.vel ~= nil and getmetatable(tab.vel) ~= Vector then
			tab.vel = Vector:vec2(tab.vel.x or 0, tab.vel.y or 0)
		end
		if tab.accel ~= nil and getmetatable(tab.accel) ~= Vector then
			tab.accel = Vector:vec2(tab.accel.x or 0, tab.accel.y or 0)
		end
		if tab.scale ~= nil and getmetatable(tab.scale) ~= Vector then
			tab.scale = Vector:numpair(tab.scale.x or 0, tab.scale.y or 0)
		end
		self.wrapped:explod(tab)

		-- support facing+vfacing (not supported in the Elecbyte implementation)
		-- [explod addr]+0x114 is a bitflag for horizontal and vertical flips.
		-- 01b = flip horizontally
		-- 10b = flip vertically
		-- 11b = flip both (of course)
		-- whether the flag is set or unset depends both on the owner's facing and on the explod's facing params.
		-- i add flag 100b to determine if an explod was already processed (as we aren't returned the addr from the wrapped func)

		-- read explod params
		local facing = tab.facing or 1
		local vfacing = tab.vfacing or 1
		local bitflag = 4 -- defaults 4 to help flag if an explod was processed by this code...

		-- compute bitflag
		if facing ~= self:facing() then bitflag = bitflag + 1 end
		if vfacing == -1 then bitflag = bitflag + 2 end
		
		-- handle undefined ID
		tab.id = tab.id or 0
		
		-- get explod addr by iterating explods and finding the one with the right ID, 0f existence, and not processed by us.
		-- this is pretty messy but probably no better method as MUGEN doesn't pass back the real explod addr.
		local explodBase = mll.ReadInteger(mll.ReadInteger(mugen.getbaseaddress() + 0x10C20))

		local idx = 0
		-- explod list entry is slightly longer in 1.1b1
		local listOffset = 0x268
		local bitflagOffset = 0x114
		if mll.GetMugenVersion() == 2 then 
			listOffset = 0x270
			bitflagOffset = 0x118
		end
		-- iterate
		while idx < mugen.explodmax() do
			local explodAddr = explodBase + (idx * listOffset)
			-- check explod exists and explod owner ID matches
			if mll.ReadInteger(explodAddr) ~= 0 and mll.ReadInteger(explodAddr + 0x0C) == self:id() then
				-- check explod ID 
				if mll.ReadInteger(explodAddr + 0x10) == tab.id and mll.ReadInteger(explodAddr + 0x154) == 0 then
					-- use a flag to avoid updating facing on this explod again (this is a hack...)
					if mll.ReadInteger(explodAddr + bitflagOffset) <= 3 then
						mll.WriteInteger(explodAddr + bitflagOffset, bitflag)
						break
					end
				end
			end
			idx = idx + 1
		end
	end
	function player:changestate(tab) 
		if tab.ctrl ~= nil then tab.ctrl = int2bool(tab.ctrl) end
		self.wrapped:changestate(tab) 
	end
	
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

	-- hooks
	function player:SetHook(h, f, p)
		-- validate hook can be placed
		if h < hooks.MIN_LISTENER or h > hooks.MAX_LISTENER then return false end
		-- default params
		if p == nil then p = {} end
		-- add target param
		p.target = self
		-- set the hook
		hooks.SetHook(h, f, p, false)
	end
	
	-- utility on object
	function player:getplayeraddress() return self.address end
	function player:getinfoaddress() return mll.ReadInteger(self.address) end
	function player:getfolder() return mll.ReadString(mll.ReadInteger(self:getinfoaddress() + 0xB0)) end

	-- returns a single explod object by ID, or nil if none exists
	-- if `id` is nil, this will error
	function player:getexplod(id)
		local manager = explodmanager:new(self)
		return manager:first(id)
	end

	-- returns a list of explods for the given ID
	-- if `id` is nil, returns the fulle explod list for this player
	function player:getexplods(id)
		local manager = explodmanager:new(self)
		if id ~= nil then return manager:iditerator(id) else return manager:iterator() end
	end

	function player:anim(animno)
		local manager = animmanager:new(self)
		return manager:animfromid(animno)
	end

	function player:animations()
		local manager = animmanager:new(self)
		return manager:iterator()
	end

	function player:animelemat(i)
		local a = self:anim(self:animno())
		for e in a:elements() do
			if e:start() <= i and (e:start() + e:length()) >= i then return e.index end
		end
		return -1
	end

	function player:state(stateno)
		local manager = statemanager:new(self)
		return manager:statefromid(stateno)
	end

	function player:states()
		local manager = statemanager:new(self)
		return manager:iterator()
	end

	-- returns the partner as a player (returns the root's partner if this player is a helper).
	-- returns nil if the partner does not exist.
	function player:partner()
		if self:ishelper() then
			local root = self:root()
			-- safeguard against weirdness if addresses were manually edited
			if root:id() == self:id() then return nil end
			return root:partner()
		end
		
		local partnerID = nil
		for p in player.player_iter() do
			if p:teamside() == self:teamside() and not p:ishelper() then
				partnerID = p:id()
				break
			end
		end
		if partnerID == nil then return nil end
		return player.playerfromid(partnerID)
	end
	-- returns the parent as a player (or `self` if this player has no parent)
	function player:parent()
		local parentAddr = mll.ReadInteger(self:getplayeraddress() + 0x164C)
		if parentAddr == 0 then return self end
		local parentID = mll.ReadInteger(parentAddr + 0x04)
		return player.playerfromid(parentID)
	end
	-- returns the root as a player (or `self` if this player has no root)
	function player:root()
		local rootAddr = mll.ReadInteger(self:getplayeraddress() + 0x1650)
		if rootAddr == 0 then return self end
		local rootID = mll.ReadInteger(rootAddr + 0x04)
		return player.playerfromid(rootID)
	end
	-- returns the state owner as a player (or `self` if this player is not custom stated)
	function player:stateowner()
		local ownerIndex = mll.ReadInteger(self:getplayeraddress() + 0xCB8)
		if ownerIndex == -1 then return self end
		if not player.indexisvalid(ownerIndex) then return self end
		return player.getplayer(ownerIndex)
	end
	-- returns the `n`th enemy as a player (or `nil` if there is no enemy)
	-- if `n` is omitted returns the first enemy
	function player:enemy(n)
		local idx = n or 0
		local c = -1
		for p in player.player_iter() do
			if p:teamside() ~= self:teamside() and not p:ishelper() then
				c = c + 1
			end
			if c == idx then return p end
		end
		return nil
	end

	-- returns the `n`th target as a player (or `nil` if there is no target)
	-- if `n` is omitted returns the first target
	function player:target(n)
		local idx = n or 0

		local targetData = mll.ReadInteger(self:getplayeraddress() + 0x2C8)
		local numTarget = mll.ReadInteger(targetData + 0x08)
		if idx > numTarget then return nil end

		local targetList = mll.ReadInteger(targetData + 0x18)
		local targetAddr = mll.ReadInteger(targetList + 0x1C * idx)
		local targetPlayerID = mll.ReadInteger(targetAddr + 0x04)
		return player.playerfromid(targetPlayerID)
	end

	-- state controllers and pseudo-state controllers
	function player:ctrlset(tab) 
		if tab.value ~= nil then tab.value = bool2int(tab.value) end
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

	function player:posset(tab)
		local x = tab.x or self:pos().x
		local y = tab.y or self:pos().y

		mll.WriteDouble(self:getplayeraddress() + 0x1F8, x)
		mll.WriteDouble(self:getplayeraddress() + 0x200, y)
	end

	function player:velset(tab)
		local x = tab.x or self:vel().x
		local y = tab.y or self:vel().y

		mll.WriteDouble(self:getplayeraddress() + 0x248, x)
		mll.WriteDouble(self:getplayeraddress() + 0x250, y)
	end

	function player:velmul(tab)
		local x = (tab.x or 1.0) * self:vel().x
		local y = (tab.y or 1.0) * self:vel().y

		mll.WriteDouble(self:getplayeraddress() + 0x248, x)
		mll.WriteDouble(self:getplayeraddress() + 0x250, y)
	end

	function player:changeanim(tab)
		if tab.value == nil then return end
		local elem = (tab.elem or 1) - 1

		local a = self:anim(tab.value)
		if a == nil then
			mugen.log("Failed to ChangeAnim - no such anim " .. tab.value .. ".\n")
			return
		end

		if a:elementcount() == 0 then
			mugen.log("Failed to ChangeAnim - animation " .. tab.value .. " has zero elements.\n")
			return
		end
		if elem > a:elementcount() then
			mugen.log("Failed to ChangeAnim - anim " .. tab.value .. " has no " .. elem .. "th element.\n")
			return
		end

		-- get the current and next elements
		local current_element = a:element(elem)
		local next_element = a:element(elem + 1)
		local next_element_index = elem + 1
		if next_element == nil then
			next_element = a:element(0)
			next_element_index = 1
		end

		local animpointer = mll.ReadInteger(self:getplayeraddress() + 0x1534)
		mll.WriteInteger(animpointer + 0x0C, a:index()) -- index of anim in anim data list
		mll.WriteInteger(animpointer + 0x10, current_element.dataaddr) -- pointer to data block for the first elem
		mll.WriteInteger(animpointer + 0x14, next_element.dataaddr) -- pointer to data block for the next elem

		mll.WriteInteger(animpointer + 0x18, 0x00) -- AnimElemNo(0) (minus 1 since zero-indexed here)
		mll.WriteInteger(animpointer + 0x1C, 0x00) -- time since last ChangeAnim
		mll.WriteInteger(animpointer + 0x20, 0x00) -- time since this loop of anim started
		mll.WriteInteger(animpointer + 0x24, next_element_index)
	end

	function player:trans(tab)
		local alpha = tab.alpha or {}
		local source_alpha = alpha.source or 256
		local dest_alpha = alpha.dest or 0

		local trans_code = mll.ReadInteger(self:getplayeraddress() + 0x14E4)
		local trans_string = string.lower(tab.trans)
		if trans_string == "none" then trans_code = 0 end
		if trans_string == "add" then trans_code = 1 end
		if trans_string == "add1" then
			trans_code = 1 
			source_alpha = 256
			dest_alpha = 128
		end
		if trans_string == "sub" then trans_code = 2 end
		if trans_string == "addalpha" then trans_code = 3 end

		mll.WriteInteger(self:getplayeraddress() + 0x14E4, trans_code)
		mll.WriteInteger(self:getplayeraddress() + 0x14E8, source_alpha)
		mll.WriteInteger(self:getplayeraddress() + 0x14EC, dest_alpha)
	end

	function player:screenbound(tab)
		local value = tab.value or 0
		if tab.value ~= nil then tab.value = bool2int(tab.value) end
		local movex = 0
		local movey = 0
		if tab.movecamera ~= nil then
			movex = tab.movecamera.x or 0
			if tab.movecamera.x ~= nil then tab.movecamera.x = bool2int(tab.movecamera.x) end
			movey = tab.movecamera.y or 0
			if tab.movecamera.y ~= nil then tab.movecamera.y = bool2int(tab.movecamera.y) end
		end

		mll.WriteInteger(self:getplayeraddress() + 0x28C, value)
		mll.WriteInteger(self:getplayeraddress() + 0x290, movex)
		mll.WriteInteger(self:getplayeraddress() + 0x294, movey)
	end

	function player:checkscreenbound()
		local value = mll.ReadInteger(self:getplayeraddress() + 0x28C)
		local movex = mll.ReadInteger(self:getplayeraddress() + 0x290)
		local movey = mll.ReadInteger(self:getplayeraddress() + 0x294)

		return {value = value, movecamera = {x = movex, y = movey}}
	end

	function player:_applyassertspecial(flag)
		flag = string.lower(flag)
		if flag == "intro" then mll.WriteByte(mugen.getbaseaddress() + 0x1269C, 0x01)
		elseif flag == "roundnotover" then mll.WriteByte(mugen.getbaseaddress() + 0x1269D, 0x01)
		elseif flag == "noko" then mll.WriteByte(mugen.getbaseaddress() + 0x1269E, 0x01)
		elseif flag == "nokosnd" then mll.WriteByte(mugen.getbaseaddress() + 0x1269F, 0x01)
		elseif flag == "nokoslow" then mll.WriteByte(mugen.getbaseaddress() + 0x126A0, 0x01)
		elseif flag == "nomusic" then mll.WriteByte(mugen.getbaseaddress() + 0x126A1, 0x01)
		elseif flag == "globalnoshadow" then mll.WriteByte(mugen.getbaseaddress() + 0x126A2, 0x01)
		elseif flag == "timerfreeze" then mll.WriteByte(mugen.getbaseaddress() + 0x126A3, 0x01)
		elseif flag == "nobardisplay" then mll.WriteByte(mugen.getbaseaddress() + 0x126A4, 0x01)
		elseif flag == "nobg" then mll.WriteByte(mugen.getbaseaddress() + 0x126A5, 0x01)
		elseif flag == "nofg" then mll.WriteByte(mugen.getbaseaddress() + 0x126A6, 0x01)
		elseif flag == "nostandguard" then mll.WriteByte(self:getplayeraddress() + 0x2AC, 0x01)
		elseif flag == "nocrouchguard" then mll.WriteByte(self:getplayeraddress() + 0x2AD, 0x01)
		elseif flag == "noairuard" then mll.WriteByte(self:getplayeraddress() + 0x2AE, 0x01)
		elseif flag == "noautoturn" then mll.WriteByte(self:getplayeraddress() + 0x2AF, 0x01)
		elseif flag == "noshadow" then mll.WriteByte(self:getplayeraddress() + 0x2B0, 0x01)
		elseif flag == "nojugglecheck" then mll.WriteByte(self:getplayeraddress() + 0x2B1, 0x01)
		elseif flag == "nowalk" then mll.WriteByte(self:getplayeraddress() + 0x2B2, 0x01)
		elseif flag == "unguardable" then mll.WriteByte(self:getplayeraddress() + 0x2B3, 0x01)
		elseif flag == "invisible" then mll.WriteByte(self:getplayeraddress() + 0x2B4, 0x01)
		end
	end

	function player:assertspecial(tab)
		if tab.flag ~= nil then self:_applyassertspecial(tab.flag) end
		if tab.flag2 ~= nil then self:_applyassertspecial(tab.flag2) end
		if tab.flag3 ~= nil then self:_applyassertspecial(tab.flag3) end
	end

	function player:selfstate(tab)
		mll.WriteInteger(self:getplayeraddress() + 0xCB8, -1) -- state owner ID
		mll.WriteInteger(self:getplayeraddress() + 0xCC8, 0) -- anim owner ID
		
		mll.WriteInteger(self:getplayeraddress() + 0xCBC, 0) -- state code pointer
		mll.WriteInteger(self:getplayeraddress() + 0xCC0, 0) -- AI data pointer?

		self:statenoset(tab.value)
		self:timeset(0)
		if tab.anim ~= nil then self:changeanim({value = tab.anim}) end
		if tab.ctrl ~= nil then self:ctrlset({ value = tab.ctrl }) end
	end

	function player:modifyexplod(tab)
		-- requires id param in the table
		if tab.id == nil then return end
		-- supported params:
		-- pos, vel, accel, scale, angle, removetime, sprpriority, ontop
		-- maybe anim?

		-- read explod list base addr
		local explodBase = mll.ReadInteger(mll.ReadInteger(mugen.getbaseaddress() + 0x10C20))

		local idx = 0
		-- explod list entry is slightly longer in 1.1b1
		local listOffset = 0x268
		local bitflagOffset = 0x114
		if mll.GetMugenVersion() == 2 then 
			listOffset = 0x270
			bitflagOffset = 0x118
		end
		-- iterate
		while idx < mugen.explodmax() do
			local explodAddr = explodBase + (idx * listOffset)
			-- check explod exists and explod owner ID matches
			if mll.ReadInteger(explodAddr) ~= 0 and mll.ReadInteger(explodAddr + 0x0C) == self:id() then
				-- check explod ID 
				if mll.ReadInteger(explodAddr + 0x10) == tab.id then
					-- modify the explod's properties
					if tab.removetime ~= nil then
						mll.WriteInteger(explodAddr + 0x154, 0)
						mll.WriteInteger(explodAddr + 0xA4, tab.removetime)
					end

					if tab.pos ~= nil then
						if tab.pos.x ~= nil then mll.WriteDouble(explodAddr + 0x18, tab.pos.x) end
						if tab.pos.y ~= nil then mll.WriteDouble(explodAddr + 0x20, tab.pos.y) end
					end

					if tab.vel ~= nil then
						if tab.vel.x ~= nil then mll.WriteDouble(explodAddr + 0x40, tab.vel.x) end
						if tab.vel.y ~= nil then mll.WriteDouble(explodAddr + 0x48, tab.vel.y) end
					end

					if tab.accel ~= nil then
						if tab.accel.x ~= nil then mll.WriteDouble(explodAddr + 0x68, tab.accel.x) end
						if tab.accel.y ~= nil then mll.WriteDouble(explodAddr + 0x70, tab.accel.y) end
					end

					if tab.scale ~= nil then
						if tab.scale.x ~= nil then mll.WriteDouble(explodAddr + 0xA8, tab.scale.x / self:scalefactor()) end
						if tab.scale.y ~= nil then mll.WriteDouble(explodAddr + 0xB0, tab.scale.y / self:scalefactor()) end
					end

					-- compute bitflag for facings
					local bitflag = mll.ReadInteger(explodAddr + bitflagOffset)

					if tab.vfacing ~= nil then
						if tab.vfacing == -1 then bitflag = bitoper(bitflag, 2, OR) end
					end

					if tab.facing ~= nil then
						if tab.facing ~= self:facing() then 
							bitflag = bitoper(bitflag, 1, OR)
						elseif bitoper(bitflag, 1, AND) == 1 then
							bitflag = bitflag - 1
						end
					end

					bitflag = bitoper(bitflag, 4, OR)
					mll.WriteInteger(explodAddr + bitflagOffset, bitflag)
				end
			end
			idx = idx + 1
		end
	end

	-- plays music from a file on disk, path provided should be relative to the character path
	-- options should be a table with any of the following options:
	---- loops - specifies how many times to loop the music. specify -1 to loop indefinitely. default: 0
	---- volume - specifies volume of the file. should be a float between 0 and 1.
	---- fade - specifies number of ms to fade in for.
	function player:playmusic(file, options)
		-- ensure options table is supplied
		if options == nil then options = {} end

		-- default values for options
		if options.loops == nil then options.loops = 0 end

		-- set volume if specified
		if options.volume ~= nil then 
			if options.volume > 1.0 then options.volume = 1.0 end
			if options.volume < 0.0 then options.volume = 0.0 end
			music.SetMusicVolume(math.floor(options.volume * 128)) 
		end

		-- play music
		local folder = self:getfolder()
		local status = false
		if options.fade == nil then 
			status = music.PlayMusic(folder .. "/" .. file, options.loops)
		else
			status = music.PlayMusicWithFadeIn(folder .. "/" .. file, options.loops, options.fade)
		end

		return status
	end

	function player:stopmusic()
		music.StopMusic()
	end

	-- not quite the same as TargetState. this will force the `self` player to run the state `stateno` under `stateowner`'s statefile.
	-- `time` is an optional argument, if provided, it sets the `Time` trigger. if not provided, `Time` is reset to 0.
	function player:forcecustomstate(stateowner, stateno, time)
		mll.WriteInteger(self:getplayeraddress() + 0xCB8, player.indexfromid(stateowner:id())) -- state owner ID
		mll.WriteInteger(self:getplayeraddress() + 0xCC8, player.indexfromid(stateowner:id())) -- anim owner ID

		local ownerStateCodePointer = mll.ReadInteger(stateowner:getinfoaddress() + 0x42C)
		mll.WriteInteger(self:getplayeraddress() + 0xCBC, ownerStateCodePointer) -- state code pointer
		mll.WriteInteger(self:getplayeraddress() + 0xCC0, stateowner:getinfoaddress() + 0x41C) -- AI data pointer?

		self:statenoset(stateno)
		self:timeset(time or 0)
	end
	
	-- getters
	function player:scalefactor() return self:localcoord().x / mll.ReadInteger(mugen.getbaseaddress() + 0x128A8) end
	function player:displayname() return mll.ReadString(self:getinfoaddress() + 0x30) end
	function player:localcoord() return {x = mll.ReadDouble(self:getinfoaddress() + 0x90), y = mll.ReadDouble(self:getinfoaddress() + 0x98)} end
	function player:isfrozen() return mll.ReadInteger(self:getplayeraddress() + 0x1B4) end
	function player:time() return mll.ReadInteger(self:getplayeraddress() + 0xED4) end
	function player:guardflag() return mll.ReadInteger(self:getplayeraddress() + 0xEE8) end
	function player:helperid() return mll.ReadInteger(self:getplayeraddress() + 0x1644) end
	function player:parentid() return mll.ReadInteger(self:getplayeraddress() + 0x1648) end
	function player:helpertype() return mll.ReadInteger(self:getplayeraddress() + 0x1654) end
	function player:stateno() return mll.ReadInteger(self:getplayeraddress() + 0xCCC) end
	function player:prevstateno() return mll.ReadInteger(self:getplayeraddress() + 0xCD0) end
	function player:facing() return mll.ReadInteger(self:getplayeraddress() + 0x1E8) end
	function player:movecontact() return mll.ReadInteger(self:getplayeraddress() + 0xF0C) end
	function player:animcount() 
		local manager = animmanager:new(self)
		return manager:count()
	end

	-- setters
	function player:nameset(value) mll.WriteString(self:getinfoaddress() + 0x00, value) end
	function player:displaynameset(value) mll.WriteString(self:getinfoaddress() + 0x30, value) end
	function player:authornameset(value) mll.WriteString(self:getinfoaddress() + 0x60, value) end
	function player:idset(value) mll.WriteInteger(self:getplayeraddress() + 0x04, value) end
	function player:teamsideset(value) mll.WriteInteger(self:getplayeraddress() + 0x0C, value) end
	function player:ishelperset(value) mll.WriteInteger(self:getplayeraddress() + 0x1C, value) end
	function player:juggleset(value) mll.WriteInteger(self:getplayeraddress() + 0x64, value) end
	function player:isfrozenset(value) mll.WriteInteger(self:getplayeraddress() + 0x1B4, value) end
	function player:lifemaxset(value) 
		if value == 0 then 
			mugen.log("Refusing to set LifeMax to 0 - this will crash your game.\n") 
			return
		end
		mll.WriteInteger(self:getplayeraddress() + 0x1BC, value) 
	end
	function player:powermaxset(value) 
		if value == 0 then 
			mugen.log("Refusing to set PowerMax to 0 - this will crash your game?\n") 
			return
		end
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