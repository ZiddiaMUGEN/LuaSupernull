# Hooks

Hooks are an event system for the Lua library. The idea behind providing an event system is that the MUGEN game engine does not execute everything which affects a character at exactly the same time. To give a simple example, if you are trying to apply a VelSet to the opponent through Lua (i.e. `player.current():enemy():velset({x = 1.0, y = 1.0})`), but the opponent has a VelSet in their own state files, their VelSet will take priority over your Lua. This is because velocity is applied after each player finishes executing their states, so the VelSet applied by the opponent is the last one activated.

In order to work around cases like these, hooks are provided for you to trigger Lua code based on specific events (returning to the above example, the hook `OnPlayerStateExecutionOver` triggers a Lua function when the target player finishes executing their states, allowing you to re-apply the VelSet later than the opponent is able to).

Note that currently, any functions you set up for a hook to trigger will only trigger once and then be freed (so if you want to trigger a function every frame, you should re-add the hook every frame). This will probably change in the near future.

## Hook Function

The function you set up to be executed by the hook should accept two parameters, `target` and `event`. The value of `target` will depend on how you have configured the hook (for example, if you are using `player:SetHook`, `target` will always be the player object you called this on). `event` will be a table containing parameters which may depend on the hook being invoked. `event.type` will always indicate the hook type, and `event.params` will store any custom parameters fed to the hook at setup time.

## Example

Here is an example of how to execute the scenario described above:

```lua
function forceEnemyVelSet(target, event)
    mugen.log("Force-setting target velocity to (1,1).\n")
    target:velset({x = 1, y = 1})
end

player.current():enemy():SetHook(hooks.OnPlayerStateExecutionOver, forceEnemyVelSet)
```

You also have the option of using anonymous functions if you're not planning on re-using the listener function.

```lua
player.current():enemy():SetHook(hooks.OnPlayerStateExecutionOver, function(target, event)
    target:velset({x = 1, y = 1})
end)
```

## Available Hooks

`hooks.OnPlayerStateExecutionOver` - Run once per frame for each player, after they finish executing their state code. The parameters for this hook must always include a value `target` indicating the target of the event.

## Functions

`player:SetHook(t, f, p)` - Add a function `f` to be executed when the hook `h` is triggered. The hook will be automatically configured to target the player object this was called against. `f` should be a function accepting two parameters `target` and `event` as described above. `p` is an optional argument which can contain any number of extra parameters you want to pass to your event function when triggered.

`hooks.SetHook(t, f, p)` - Add a function `f` to be executed when the hook `h` is triggered. It's generally not recommended to use this function directly, and instead to use target-specific hook setup functions such as `player:SetHook`. `f` should be a function accepting two parameters `target` and `event` as described above. `p` should be a table of optional parameters which will depend on the hook being triggered. You can include any number of extra parameters in this table, which will be provided directly to `f` in `event.params`.

