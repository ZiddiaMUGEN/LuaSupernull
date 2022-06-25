local animmanager = {}
animmanager.__index = animmanager

-- constructor, stores the address to the animation root pointer
-- p should be a player object, so the controller can reference the player address.
function animmanager:new(p)
    a = { }
    setmetatable(a, self)
    a.address = mll.ReadInteger(mll.ReadInteger(mll.ReadInteger(p:getplayeraddress() + 0x1534)))
    return a
end

-- utility, anim controller is able to access anim pointers and anim count
function animmanager:animinfolist() return mll.ReadInteger(self.address + 0x1C) end
function animmanager:animdatalist() return mll.ReadInteger(self.address + 0x18) end
function animmanager:count() return mll.ReadInteger(self.address + 0x08) end

-- iterator over each anim, builds a new anim object from each
function animmanager:iterator()
    local idx = -1
    return function ()
        idx = idx + 1
        if idx < self:count() then return anim:new(self:animinfolist() + 0x10 * idx, self:animdatalist() + 0x14 * idx) end
    end
end

-- iterates over all animations until we find one with a matching ID
-- returns nil if none is found
function animmanager:animfromid(id)
    for a in self:iterator() do
        if a:id() == id then return a end
    end
    return nil
end

function animmanager:animfromindex(idx)
    if idx >= self:count() then return nil end
    return anim:new(self:animinfolist() + 0x10 * idx, self:animdatalist() + 0x14 * idx)
end

_G.animmanager = animmanager

local anim = {}
anim.__index = anim

-- constructor, stores info + data addresses
function anim:new(info, data)
    a = { }
    setmetatable(a, self)
    a.infoaddr = info
    a.dataaddr = data
    return a
end

function anim:elemdatalist() return mll.ReadInteger(mll.ReadInteger(self.dataaddr) + 0x18) end

function anim:id() return mll.ReadInteger(self.infoaddr + 0x0C) end
function anim:elementcount() return mll.ReadInteger(mll.ReadInteger(self.dataaddr) + 0x08) end
function anim:index() return mll.ReadInteger(self.infoaddr + 0x04) end
function anim:length() return mll.ReadInteger(self.dataaddr + 0x08) end
function anim:hasloop() return mll.ReadInteger(self.dataaddr + 0x10) ~= 0 end
function anim:loop() return {frame = mll.ReadInteger(self.dataaddr + 0x0C), element = mll.ReadInteger(self.dataaddr + 0x10)} end

-- fetch element at index
function anim:element(idx)
    if idx >= self:elementcount() then return nil end
    return element:new(self:elemdatalist() + 0x8C * idx)
end

-- iterator over elements
function anim:elements()
    local idx = -1
    return function ()
        idx = idx + 1
        if idx < self:elementcount() then return self:element(idx) end
    end
end

_G.anim = anim

local element = {}
element.__index = element

function element:new(data)
    a = { }
    setmetatable(a, self)
    a.dataaddr = data
    return a
end

function element:clsn1data() return mll.ReadInteger(self.dataaddr + 0x84) end
function element:clsn2data() return mll.ReadInteger(self.dataaddr + 0x88) end

function element:length() return mll.ReadInteger(self.dataaddr + 0x04) end
function element:hasclsn1() return self:clsn1data() ~= 0 end
function element:hasclsn2() return self:clsn2data() ~= 0 end
function element:clsn1count() 
    if not self:hasclsn1() then return 0 end
    return mll.ReadInteger(self:clsn1data() + 0x04) 
end
function element:clsn2count() 
    if not self:hasclsn2() then return 0 end
    return mll.ReadInteger(self:clsn2data() + 0x04) 
end

function element:clsn1()
    local idx = -1
    return function()
        idx = idx + 1
        if self:hasclsn1() and idx < self:clsn1count() then 
            local definition = mll.ReadInteger(self:clsn1data() + 0x08)
            return {
                left = mll.ReadInteger(definition + 0x04),
                top = mll.ReadInteger(definition + 0x08),
                right = mll.ReadInteger(definition + 0x0C),
                bottom = mll.ReadInteger(definition + 0x10)
            } 
        end
    end
end

function element:clsn2()
    local idx = -1
    return function()
        idx = idx + 1
        if self:hasclsn2() and idx < self:clsn2count() then 
            local definition = mll.ReadInteger(self:clsn2data() + 0x08)
            return {
                left = mll.ReadInteger(definition + idx*0x14 + 0x04),
                top = mll.ReadInteger(definition + idx*0x14 + 0x08),
                right = mll.ReadInteger(definition + idx*0x14 + 0x0C),
                bottom = mll.ReadInteger(definition + idx*0x14 + 0x10)
            } 
        end
    end
end

_G.element = element