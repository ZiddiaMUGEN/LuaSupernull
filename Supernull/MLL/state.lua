local statemanager = {}
statemanager.__index = statemanager

-- constructor, stores the address to the statedef root pointer
-- p should be a player object, so the controller can reference the player address.
function statemanager:new(p)
    a = { }
    setmetatable(a, self)
    a.address = mll.ReadInteger(mll.ReadInteger(p:getinfoaddress() + 0x42C))
    return a
end

-- utility, state controller is able to access state pointers and state count
function statemanager:stateinfolist() return mll.ReadInteger(self.address + 0x1C) end
function statemanager:statedatalist() return mll.ReadInteger(self.address + 0x18) end
function statemanager:count() return mll.ReadInteger(self.address + 0x08) end

-- iterator over each state, builds a new state object from each
function statemanager:iterator()
    local idx = -1
    return function ()
        idx = idx + 1
        if idx < self:count() then return state:new(self:stateinfolist() + 0x10 * idx, self:statedatalist() + 0x9C * idx) end
    end
end

-- iterates over all stateations until we find one with a matching ID
-- returns nil if none is found
function statemanager:statefromid(id)
    for a in self:iterator() do
        if a:stateno() == id then return a end
    end
    return nil
end

function statemanager:statefromindex(idx)
    if idx >= self:count() then return nil end
    return state:new(self:stateinfolist() + 0x10 * idx, self:statedatalist() + 0x9C * idx)
end

_G.statemanager = statemanager

local state = {}
state.__index = state

-- constructor, stores info + data addresses
function state:new(info, data)
    a = { }
    setmetatable(a, self)
    a.infoaddr = info
    a.dataaddr = data
    return a
end

-- utility
function state:controllerbase() return mll.ReadInteger(self.dataaddr) end
function state:controllercount() return mll.ReadInteger(self:controllerbase() + 0x08) end
function state:controllerdata() return mll.ReadInteger(self:controllerbase() + 0x18) end
function state:controllerlist() return mll.ReadInteger(self:controllerbase() + 0x1C) end

-- statedef information
function state:stateno() return mll.ReadInteger(self.infoaddr + 0x08) end
function state:statetype() return mll.ReadInteger(self.dataaddr + 0x04) end
function state:movetype() return mll.ReadInteger(self.dataaddr + 0x08) end
function state:physics() return mll.ReadInteger(self.dataaddr + 0x0C) end
function state:juggle() return trigger:new(self.dataaddr + 0x10) end
function state:xvel() return trigger:new(self.dataaddr + 0x5C, 1) end
function state:yvel() return trigger:new(self.dataaddr + 0x68, 1) end
function state:animid() return trigger:new(self.dataaddr + 0x80) end
function state:poweradd() return trigger:new(self.dataaddr + 0x8C) end

-- fetch controller at index
function state:controller(idx)
    if idx >= self:controllercount() then return nil end
    return controller:new(self:controllerlist() + 0x10 * idx, self:controllerdata() + 0x68 * idx)
end

-- iterator over controllers
function state:controllers()
    local idx = -1
    return function ()
        idx = idx + 1
        if idx < self:controllercount() then return self:controller(idx) end
    end
end

_G.state = state

local controller = {}
controller.__index = controller

-- constructor, stores info + data addresses
function controller:new(info, data)
    a = { }
    setmetatable(a, self)
    a.infoaddr = info
    a.dataaddr = data
    return a
end

-- utility
function controller:triggerbase() return mll.ReadInteger(self.dataaddr + 0x00) end
function controller:triggercount() return mll.ReadInteger(self.dataaddr + 0x04) end

-- state controller information
function controller:persistent() return mll.ReadInteger(self.dataaddr + 0x08) end
function controller:ignorehitpause() return mll.ReadInteger(self.dataaddr + 0x0C) end
function controller:type() return mll.ReadInteger(self.infoaddr + 0x08) end

-- fetches properties for the state controller. major WIP.
function controller:properties()
    if self:type() == 0x01 then
        -- ChangeState
        return {value = trigger:new(self.dataaddr + 0x18)}
    elseif self:type() == 0x20 then
        -- ChangeAnim
        return {value = trigger:new(self.dataaddr + 0x18)}
    elseif self:type() == 0x0C then
        -- PowerSet
        return {value = trigger:new(self.dataaddr + 0x18)}
    elseif self:type() == 0x0D then
        -- PowerAdd
        return {value = trigger:new(self.dataaddr + 0x18)}
    elseif self:type() == 0x1E then
        -- NotHitBy
        return {value = trigger:new(self.dataaddr + 0x18), time = trigger:new(self.dataaddr + 0x24)}
    elseif self:type() == 0xD6 then
        -- SuperPause
        local extension = mll.ReadInteger(self.dataaddr + 0x60)
        return {poweradd = trigger:new(extension + 0x70)}
    elseif self:type() == 0x16 then
        -- PosAdd
        return {x = trigger:new(self.dataaddr + 0x3C, 1), y = trigger:new(self.dataaddr + 0x48, 1)}
    elseif self:type() == 0x18 then
        -- VelSet
        return {x = trigger:new(self.dataaddr + 0x3C, 1), y = trigger:new(self.dataaddr + 0x48, 1)}
    elseif self:type() == 0x25 then
        -- HitDef
        -- separate this into another function just for readability...
        return self:_hitdef()
    end
end

function controller:_hitdef()
    local extension = mll.ReadInteger(self.dataaddr + 0x60)
    return {
        affectteam = trigger_:new(mll.ReadInteger(extension + 0x00)),
        hitdefattr = trigger_:new(mll.ReadInteger(extension + 0x04)),
        id = trigger:new(extension + 0x08),
        chainid = trigger:new(extension + 0x14),
        nochainid1 = trigger:new(extension + 0x20),
        nochainid2 = trigger:new(extension + 0x2C),
        kill = trigger:new(extension + 0x38),
        guardkill = trigger:new(extension + 0x44),
        fallkill = trigger:new(extension + 0x50),
        hitonce = trigger:new(extension + 0x5C),
        airjuggle = trigger:new(extension + 0x68),
        hitdamage = trigger:new(extension + 0x74),
        guarddamage = trigger:new(extension + 0x80),
        hitgetpower = trigger:new(extension + 0x8C),
        guardgetpower = trigger:new(extension + 0x98),
        hitgivepower = trigger:new(extension + 0xA4),
        guardgivepower = trigger:new(extension + 0xB0),
        hitshaketime = trigger:new(extension + 0xBC),
        hitpausetime = trigger:new(extension + 0xC8),
        numhits = trigger:new(extension + 0xD4),
        hitsoundgroup = trigger:new(extension + 0xE0),
        hitsoundindex = trigger:new(extension + 0xEC),
        guardsoundgroup = trigger:new(extension + 0xFC),
        guardsoundindex = trigger:new(extension + 0x108),
        guardflag = trigger_:new(mll.ReadInteger(extension + 0x118)),
        hitflag = trigger_:new(mll.ReadInteger(extension + 0x11C)),
        priorityval = trigger:new(extension + 0x120),
        prioritytype = trigger:new(extension + 0x12C),
        p1stateno = trigger:new(extension + 0x130),
        p2stateno = trigger:new(extension + 0x13C),
        p2getp1state = trigger:new(extension + 0x148),
        sprpriority = trigger:new(extension + 0x160),
        p2sprpriority = trigger:new(extension + 0x16C),
        animtype = trigger_:new(mll.ReadInteger(extension + 0x178)),
        forcestand = trigger:new(extension + 0x17C),
        forcenofall = trigger:new(extension + 0x188),
        falldamage = trigger:new(extension + 0x19C),
        fallanimtype = trigger_:new(mll.ReadInteger(extension + 0x1A8)),
        fallxvelocity = trigger:new(extension + 0x1AC, 1),
        fallyvelocity = trigger:new(extension + 0x1B8, 1),
        fallrecover = trigger:new(extension + 0x1C4),
        fallrecovertime = trigger:new(extension + 0x1D0),
        fall = trigger:new(extension + 0x21C),
        sparkno = trigger:new(extension + 0x228),
        sparkno_uses_player_air = trigger_:new(mll.ReadInteger(extension + 0x234)),
        guardsparkno = trigger:new(extension + 0x238),
        guardsparkno_uses_player_air = trigger_:new(mll.ReadInteger(extension + 0x244)),
        sparkx = trigger:new(extension + 0x248),
        sparky = trigger:new(extension + 0x254),
        p1facing = trigger:new(extension + 0x260),
        p1getp2facing = trigger:new(extension + 0x26C),
        snapx = trigger:new(extension + 0x278),
        snapy = trigger:new(extension + 0x284),
        p2facing = trigger:new(extension + 0x2A8),
        groundtype = trigger_:new(mll.ReadInteger(extension + 0x2B4)),
        groundhittime = trigger:new(extension + 0x2B8),
        groundslidetime = trigger:new(extension + 0x2C4),
        groundvelocityx = trigger:new(extension + 0x2D0, 1),
        groundvelocityy = trigger:new(extension + 0x2DC, 1),
        groundcornerpushveloff = trigger:new(extension + 0x2E8, 1),
        airtype = trigger_:new(mll.ReadInteger(extension + 0x2F4)),
        airanimtype = trigger_:new(mll.ReadInteger(extension + 0x2F8)),
        airhittime = trigger:new(extension + 0x2FC),
        airfall = trigger:new(extension + 0x308),
        airvelocityx = trigger:new(extension + 0x314, 1),
        airvelocityy = trigger:new(extension + 0x320, 1),
        aircornerpushveloff = trigger:new(extension + 0x32C, 1),
        downbounce = trigger:new(extension + 0x338),
        downhittime = trigger:new(extension + 0x344),
        downvelocityx = trigger:new(extension + 0x350, 1),
        downvelocityy = trigger:new(extension + 0x35C, 1),
        downcornerpushveloff = trigger:new(extension + 0x368, 1),
        guardvelocity = trigger:new(extension + 0x374, 1),
        guardhittime = trigger:new(extension + 0x380),
        guardslidetime = trigger:new(extension + 0x38C),
        guardctrltime = trigger:new(extension + 0x398),
        guarddist = trigger:new(extension + 0x3A4),
        guardpausetime = trigger:new(extension + 0x3B0),
        guardshaketime = trigger:new(extension + 0x3BC),
        guardcornerpushveloff = trigger:new(extension + 0x3C8, 1),
        airguardvelocityx = trigger:new(extension + 0x3D4, 1),
        airguardvelocityy = trigger:new(extension + 0x3E0, 1),
        airguardctrltime = trigger:new(extension + 0x3EC),
        airguardcornerpushveloff = trigger:new(extension + 0x3F8, 1),
        yaccel = trigger:new(extension + 0x404, 1)
    }
end

_G.controller = controller

local trigger = {}
trigger.__index = trigger

-- constructor, stores base address
-- type is 0 for int, 1 for float
function trigger:new(addr, type)
    a = { }
    setmetatable(a, self)
    a.baseaddr = addr
    a.type = type or 0
    return a
end

-- utility
function trigger:isconstant() return mll.ReadInteger(self.baseaddr + 0x08) == -1 end

-- evals
function trigger:constant() 
    if not self:isconstant() then return 0 end
    if self.type == 0 then return mll.ReadInteger(self.baseaddr + 0x00)
    elseif self.type == 1 then 
        -- mugen represents null floats in triggers as 0xFF7FFFFF
        -- minimum 32-bit float value, but because Lua uses doubles, this is hard to compare on as a float
        -- therefore, check against int value, 0xFF7FFFFF == -8388609
        local ivalue = mll.ReadInteger(self.baseaddr + 0x00)

        if ivalue == -8388609 then return 0.0
        else return mll.ReadFloat(self.baseaddr + 0x00) end
    else return 0
    end
end

_G.trigger = trigger

-- trigger_ is an internal type to wrap always-constant values
-- this helps give a consistent interface between trigger values and non-trigger values, without requiring the user to look at documentation for every parameter
local trigger_ = {}
trigger_.__index = trigger_

function trigger_:new(value)
    a = { }
    setmetatable(a, self)
    a.value = value
    return a
end

function trigger_:isconstant() return true end
function trigger_:constant() return self.value end

_G.trigger_ = trigger_