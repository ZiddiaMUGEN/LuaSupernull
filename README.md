# Overview

This character offers a new approach to 1.1 supernulls. It still uses the basic ROP technique utilized for the original 1.1 supernull, but makes use of an exploit in 1.1's Lua engine to reduce complexity + increase stability. The trick used for this supernull revolves around the 1.1 engine's Lua sandbox. The Lua environment is not locked down sufficiently, allowing us to use unsafe commands (package.loadlib) to reach arbitrary code execution.

The main benefit of using this variant of the supernull is additional stability. By avoiding the need for functions like GetProcAddress during the ROP phase, we're able to reduce the number of dependent non-rebase DLLs from 3 to only 1. This is significant, as the vast majority of crashes I observed were due to a DLL being rebased. The 2 most commonly rebased DLLs are no longer used in the chain.

In exchange for stability, we sacrifice MUGEN 1.0 compatibility. MUGEN 1.0 does not include the Lua engine, so we can't use this trick to reach ACE. 

The basic flow for this supernull is as follows:
1. Execute AssertSpecial flag buffer overflow exploit (as per previous 1.1 supernulls)
2. Utilize ROP to execute a Lua file-loading function
3. From Lua, execute package.loadlib to load DLLs into memory
4. The DLL can then expose functions to the Lua side to execute functions, modify memory, etc.

In this example, step 4 loads a Lua runtime library DLL and a Lua FFI DLL, which allows declarations of C function prototypes in Lua which then map back and execute C API functions. Through FFI, we're able to run VirtualProtect, then modify the game code, inject our custom code from files, etc.

For some examples of this method in use (along with extensive use of the Lua library), take a look at https://github.com/ZiddiaMUGEN/Sad-Assist-2nd or https://github.com/ZiddiaMUGEN/AI-Assist

# Library

Beyond just the supernull steps, part of the goal for this project was to provide an interface for working through Lua, rather than Assembly or variable-based memory editing. This makes the Supernull concept more accessible and easier to drop into an existing character (it's much easier to just pick up Lua and write `player.current():displaynameset("NewName")` than to learn Assembly and mess with the MUGEN memory layout!).

To this end, this repository provides a small Assembly stub which patches DisplayToClipboard to allow Lua execution through your CNS code. In addition, Elecbyte has already provide a (mostly read-only) interface for players as part of the base Lua engine, but we are able to wrap and extend this to provide a much more full-featured library of functions.

# Installation

To install this package into your character, run through the following steps:

1. Place the `elua` file in the character's root directory (same folder which contains the `.def` file). This file MUST be in the same location as the `.def` or the exploit will fail and your character will crash.
2. Place the `supernull.st` file somewhere in the character folder. The rest of these steps will assume it's in the same folder as the `.def` file, and that you have not renamed the file (however, unlike for `elua`, you are free to do either of these and adjust accordingly).
3. Update the `.def` file under `[Files]` section, and set `st = supernull.st`. The `supernull.st` file MUST be set in `st` (and not e.g. `st0`, `st1`, ..., `st9`) as the payload is specifically designed for it.
4. Drop the `Supernull` folder (and all its contents) into your character folder. By default, the `elua` script expects it to be in the same folder as the `.def` file.

Note that if you opted to move the Supernull folder to a different location, you must update the configuration options at the top of the `elua` file accordingly. I recommend just leaving it in the default location for simplicity.

Once you've completed these steps, your character should be equipped with the supernull payload and ready to be used. You can test it out and see whether it crashes to validate the installation was successful. In the event of a crash, some output should be dumped into `mugen.log` with details.

# Executing Lua

To execute a Lua file from your character, you can use DisplayToClipboard functionality. The template patches DisplayToClipboard to interpret any text starting with `!lua ` as a path to a Lua file to be run. As an example, to run the Lua file `Examples/LuaSamples/FreezeCharacters.lua` from this repository, you would include the below DisplayToClipboard state controller:

```ini
[State -2, Execute Lua]
type = DisplayToClipboard
trigger1 = 1 ;; or your trigger here...
text = "!lua Examples/LuaSamples/FreezeCharacters.lua"
```

(Note the path is based on your character's folder, so in this example, `Examples` folder would be in the same location as the `.def` file).

# Working With Lua

Refer to Library.md for a detailed review of functionality exposed through Lua.

One tip I will provide here is to try to wrap your Lua script with `pcall` if at all possible. My Lua-loading function tends to swallow errors and give a generic message if any part of your code raises a warning or an error, but if you wrap with `pcall`, you will be able to get more detailed output (and your code will no longer fail on warnings). Therefore, for debugging and development, `pcall` is recommended (and it's best to just leave it at all times for simplicity and so you can debug other people's issues more easily).

Here's a template you can use which will handle errors gracefully, display them to console, and output them to `mugen.log`:

```lua
function userscript()
	-- your Lua code goes here.
end

local status, err = pcall(userscript)
if not status then
	mugen.log("Failed to run user script: " .. err .. "\n")
end
```

If you desperately need a full stack trace you can try the below instead (keep in mind stack trace may get mangled a little as we're doing a lot of sketchy moving between C and Lua):

```lua
function userscript()
	-- your Lua code goes here.
end

local co = coroutine.create(userscript)
local status, err = coroutine.resume(co)
if not status then
	mugen.log("Failed to run user script: " .. err .. "\n")
	local full_tb = debug.traceback(co)
	mugen.log(full_tb .. "\n")
end
```

Also, keep in mind that your Lua code is loaded completely fresh from file every time you trigger a DisplayToClipboard, so you can actively work on your code while the game is running and see its effects in real time.