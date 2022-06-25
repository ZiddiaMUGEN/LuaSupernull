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
function state:juggle() return mll.ReadInteger(self.dataaddr + 0x10) end
function state:animid() return mll.ReadInteger(self.dataaddr + 0x80) end

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
        return {value = mll.ReadInteger(self.dataaddr + 0x18)}
    elseif self:type() == 0x20 then
        -- ChangeAnim
        return {value = mll.ReadInteger(self.dataaddr + 0x18)}
    elseif self:type() == 0x1E then
        -- NotHitBy
        return {value = mll.ReadInteger(self.dataaddr + 0x18), time = mll.ReadInteger(self.dataaddr + 0x24)}
    elseif self:type() == 0xD6 then
        -- SuperPause
        local extension = mll.ReadInteger(self.dataaddr + 0x60)
        return {poweradd = mll.ReadInteger(extension + 0x70)}
    elseif self:type() == 0xD6 then
        -- PosAdd
        return {x = mll.ReadFloat(self.dataaddr + 0x3C), y = mll.ReadFloat(self.dataaddr + 0x48)}
    elseif self:type() == 0x25 then
        -- HitDef
        return {}
    end
end

_G.controller = controller