local hooks = {}
hooks.__index = hooks

-- global hook list
hooks.registeredHooks = {}

hooks.MIN_LISTENER = 1 -- do not use
hooks.MAX_LISTENER = 1 -- do not use

-- enumerating available hooks
hooks.OnPlayerStateExecutionOver = 1 -- triggers when the target player finishes executing state controllers for a frame.

-- adds a hook.
-- hookPersist is currently ignored.
function hooks.SetHook(hookType, hookFunc, hookParams, hookPersist)
    -- defaults
    if hookPersist == nil then hookPersist = false end
    if hookParams == nil then hookParams = {} end

    -- ensure this hook type is registered
    if hooks.registeredHooks[hookType] == nil then hooks.registeredHooks[hookType] = {} end

    -- check hookParams for the given hookType and register the hook
    if hookType == hooks.OnPlayerStateExecutionOver then
        -- validate hookParams
        if hookParams.target == nil then
            mugen.log("Failed to add hook for OnPlayerStateExecutionOver - parameter target is missing. Target should be a player object.\n")
            return
        end

        -- register the hook under the target player's ID
        local id = hookParams.target:id()
        if hooks.registeredHooks[hookType][id] == nil then hooks.registeredHooks[hookType][id] = {} end
        hooks.registeredHooks[hookType][id][#(hooks.registeredHooks[hookType][id]) + 1] = {func = hookFunc, params = hookParams, persist = hookPersist}
    end
end

function hooks.RunHook(hookType, callerParams)
    -- defaults
    if callerParams == nil then callerParams = {} end

    -- ensure this hook type is registered
    if hooks.registeredHooks[hookType] == nil then hooks.registeredHooks[hookType] = {} end

    -- run hooks based on the hookType
    if hookType == hooks.OnPlayerStateExecutionOver then
        if callerParams.target == nil then
            mugen.log("Failed to run hooks for OnPlayerStateExecutionOver - parameter target is missing. Target should be a player object.\n")
            return
        end

        local id = callerParams.target:id()
        if hooks.registeredHooks[hookType][id] == nil or #(hooks.registeredHooks[hookType][id]) == 0 then return end
        for i=1,#(hooks.registeredHooks[hookType][id]) do
            hooks.registeredHooks[hookType][id][i].func(callerParams.target, {type = hookType, params = hooks.registeredHooks[hookType][id][i].params})
        end

        hooks.registeredHooks[hookType][id] = {}
    end
end

_G.hooks = hooks