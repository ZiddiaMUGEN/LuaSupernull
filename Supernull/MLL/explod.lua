local explodmanager = {}
explodmanager.__index = explodmanager

-- constructor, stores the address to the explod root pointer
-- explod root pointer is relative to MUGEN base address
function explodmanager:new(p)
    e = { }
    setmetatable(e, self)
    e.address = mll.ReadInteger(mll.ReadInteger(mugen.getbaseaddress() + 0x10C20))
    e.owner = p:id()
    return e
end

-- iterator over each explod, builds a new explod object from each
function explodmanager:_iterator()
    local listOffset = 0x268
    if mll.GetMugenVersion() == 2 then listOffset = 0x270 end
    local idx = -1
    return function ()
        idx = idx + 1
        if idx < mugen.explodmax() then return explod:new(self.address + listOffset * idx) end
    end
end

-- iterates over all explods but only returns explods owned by this player
function explodmanager:iterator()
    local iter = self:_iterator()
    return function()
        local ele = iter()
        while ele ~= nil and (ele:owner() ~= self.owner or ele:exists() == false) do ele = iter() end
        return ele
    end
end

function explodmanager:iditerator(id)
    local iter = self:iterator()
    return function()
        local ele = iter()
        while ele ~= nil and (ele:id() ~= id  or ele:exists() == false) do ele = iter() end
        return ele
    end
end

function explodmanager:first(id)
    local iter = self:iditerator(id)
    return iter()
end

_G.explodmanager = explodmanager

local explod = {}
explod.__index = explod

-- constructor, stores the explod address
function explod:new(addr)
    e = { }
    setmetatable(e, self)
    e.address = addr
    return e
end

function explod:versioned() if mll.GetMugenVersion() == 2 then return 0x04 else return 0x00 end end

function explod:exists() return int2bool(mll.ReadInteger(self.address)) end

-- 0x18: pos x (double)
-- 0x20: pos y (double)
function explod:pos() return {x = mll.ReadDouble(self.address + 0x18), y = mll.ReadDouble(self.address + 0x20)} end
function explod:posset(x, y) 
    if x ~= nil then mll.WriteDouble(self.address + 0x18, x) end
    if y ~= nil then mll.WriteDouble(self.address + 0x20, y) end
end

-- 0x40: vel x (double)
-- 0x48: vel y (double)
function explod:vel() return {x = mll.ReadDouble(self.address + 0x40), y = mll.ReadDouble(self.address + 0x48)} end
function explod:velset(x, y) 
    if x ~= nil then mll.WriteDouble(self.address + 0x40, x) end
    if y ~= nil then mll.WriteDouble(self.address + 0x48, y) end
end

-- 0x68: accel x (double)
-- 0x70: accel y (double)
function explod:accel() return {x = mll.ReadDouble(self.address + 0x68), y = mll.ReadDouble(self.address + 0x70)} end
function explod:accelset(x, y) 
    if x ~= nil then mll.WriteDouble(self.address + 0x68, x) end
    if y ~= nil then mll.WriteDouble(self.address + 0x70, y) end
end

-- 0x8C: sprpriority
function explod:sprpriority() return mll.ReadInteger(self.address + 0x8C) end
function explod:sprpriorityset(i) mll.WriteInteger(self.address + 0x8C, i) end

-- 0x90: random x
-- 0x94: random y
function explod:random() return {x = mll.ReadInteger(self.address + 0x90), y = mll.ReadInteger(self.address + 0x94)} end
function explod:randomset(x, y) 
    if x ~= nil then mll.WriteInteger(self.address + 0x90, x) end
    if y ~= nil then mll.WriteInteger(self.address + 0x94, y) end
end

-- 0x98: pausemovetime
function explod:pausemovetime() return mll.ReadInteger(self.address + 0x98) end
function explod:pausemovetimeset(i) mll.WriteInteger(self.address + 0x98, i) end

-- 0x9C: supermovetime
function explod:supermovetime() return mll.ReadInteger(self.address + 0x9C) end
function explod:supermovetimeset(i) mll.WriteInteger(self.address + 0x9C, i) end

-- 0xA4: removetime
function explod:removetime() return mll.ReadInteger(self.address + 0xA4) end
function explod:removetimeset(i) mll.WriteInteger(self.address + 0xA4, i) end

-- 0xA8: scale x (double) (localcoord-aware)
-- 0xB0: scale y (double) (localcoord-aware)
function explod:scale() return {x = mll.ReadDouble(self.address + 0xA8), y = mll.ReadDouble(self.address + 0xB0)} end
function explod:scaleset(x, y) 
    if x ~= nil then mll.WriteDouble(self.address + 0xA8, x) end
    if y ~= nil then mll.WriteDouble(self.address + 0xB0, y) end
end

-- 0xD0: angle (double)
function explod:angle() return mll.ReadDouble(self.address + 0xD0) end
function explod:angleset(d) mll.WriteDouble(self.address + 0xD0, d) end

-- 0xD8: yangle (double)
function explod:yangle() return mll.ReadDouble(self.address + 0xD8) end
function explod:yangleset(d) mll.WriteDouble(self.address + 0xD8, d) end

-- 0xE0: xangle (double)
function explod:xangle() return mll.ReadDouble(self.address + 0xE0) end
function explod:xangleset(d) mll.WriteDouble(self.address + 0xE0, d) end

-- 0xFC: bindtime
function explod:bindtime() return mll.ReadInteger(self.address + 0xFC) end
function explod:bindtimeset(i) mll.WriteInteger(self.address + 0xFC, i) end

-- 0x10C: postype
function explod:postype() return mll.ReadInteger(self.address + 0x10C + self:versioned()) end
function explod:postypeset(i) mll.WriteInteger(self.address + 0x10C + self:versioned(), i) end

-- 0x110: ontop
function explod:ontop() return mll.ReadInteger(self.address + 0x110 + self:versioned()) end
function explod:ontopset(i) mll.WriteInteger(self.address + 0x110 + self:versioned(), i) end

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
-- 0x114: bitflag
function explod:facing()
    local bf = mll.ReadInteger(self.address + 0x114 + self:versioned())
    if bitoper(bf, 1, AND) == 1 then return -1 else return 1 end
end

function explod:vfacing()
    local bf = mll.ReadInteger(self.address + 0x114 + self:versioned())
    if bitoper(bf, 2, AND) == 2 then return -1 else return 1 end
end

-- 0x118: space (0=stage, 1=screen, -1=auto)
function explod:space() return mll.ReadInteger(self.address + 0x118 + self:versioned()) end
function explod:spaceset(i) mll.WriteInteger(self.address + 0x118 + self:versioned(), i) end

-- 0x11C: shadow
function explod:shadow() return mll.ReadInteger(self.address + 0x11C + self:versioned()) end
function explod:shadowset(i) mll.WriteInteger(self.address + 0x11C + self:versioned(), i) end

-- 0x120: removeongethit
function explod:removeongethit() return mll.ReadInteger(self.address + 0x120 + self:versioned()) end
function explod:removeongethitset(i) mll.WriteInteger(self.address + 0x120 + self:versioned(), i) end

-- 0x124: ignorehitpause
function explod:ignorehitpause() return mll.ReadInteger(self.address + 0x124 + self:versioned()) end
function explod:ignorehitpauseset(i) mll.WriteInteger(self.address + 0x124 + self:versioned(), i) end

-- 0x1E4: trans
function explod:trans() return mll.ReadInteger(self.address + 0x1E4 + self:versioned()) end
function explod:transset(i) mll.WriteInteger(self.address + 0x1E4 + self:versioned(), i) end

-- 0x1E8: alpha src
-- 0x1EC: alpha dst
function explod:alpha() return {src = mll.ReadInteger(self.address + 0x1E8 + self:versioned()), dst = mll.ReadInteger(self.address + 0x1EC + self:versioned())} end
function explod:alphaset(src, dst) 
    if src ~= nil then mll.WriteInteger(self.address + 0x1E8 + self:versioned(), src) end
    if dst ~= nil then mll.WriteInteger(self.address + 0x1EC + self:versioned(), dst) end
end

function explod:owner() return mll.ReadInteger(self.address + 0x0C) end
function explod:ownerset(i) mll.WriteInteger(self.address + 0x0C, i) end

function explod:id() return mll.ReadInteger(self.address + 0x10) end
function explod:idset(i) mll.WriteInteger(self.address + 0x10, i) end

_G.explod = explod