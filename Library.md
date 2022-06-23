# Mugen Module

The `mugen` module exposes some basic functionality for working with MUGEN. A portion of the original functionality of this module was for debugging, sandboxing, and testing purposes. Additionally, the values of some common triggers are exposed as functions.

## Original Functionality

`mugen.log(s)` - Writes the input string `s` to the `mugen.log` file, as well as to the game clipboard.

`mugen.roundreset()` - Completely restarts the current round. Includes a re-run of intros if in the first round.

`mugen.matchreload()` - Completely restarts the current match, including a complete reload of all characters.

`mugen.setroundtimeleft(i)` - Sets the remaining round time to `i` ticks. The exact number of seconds which will be displayed on the clock depends on the value of TicksPerSecond.

`mugen.togglebardisplay()` - Toggles lifebars on and off.

`mugen.random(max)` - Generates a random number, similar to the `Random` trigger. The number generated is constrained between 0 and `max`.

`mugen.gameheight()` - Returns the value of the `GameHeight` property from `mugen.cfg`.

`mugen.gamewidth()` - Returns the value of the `GameWidth` property from `mugen.cfg`.

`mugen.gametime()` - Returns the current value of the `GameTime` trigger.

`mugen.roundstate()` - Returns the current value of the `RoundState` trigger.

`mugen.tickspersecond()` - Returns the current value of the `TicksPerSecond` trigger.

`mugen.leftedge()` - Returns the left edge of the screen, in stage coordinates (as the stage scrolls, this value will adjust).

`mugen.rightedge()` - Returns the right edge of the screen, in stage coordinates (as the stage scrolls, this value will adjust).

`mugen.topedge()` - Returns the top edge of the screen, in stage coordinates (as the stage scrolls, this value will adjust).

`mugen.bottomedge()` - Returns the bottom edge of the screen, in stage coordinates (as the stage scrolls, this value will adjust).

`mugen.camerapos()` - Returns a table with indices `x`, `y`, and `z` for the float co-ordinates representing the camera position. (Access the table indices via e.g. `mugen.camerapos().x`).

`mugen.camerazoom()` - Returns the camera zoom factor.

`mugen.gamemode()` - Returns the currently-running game mode, as a string.

`mugen.gamemodecode()` - Returns the currently-running game mode, as an integer.

`mugen.language()` - Returns a string representing the current language (e.g. `en`, `jp`).

`mugen.roundtimemax()` - Returns the maximum round time (i.e. the amount of ticks set as the round timer initially). Note this does not update after running `mugen.setroundtimeleft(i)`.

`mugen.roundtimeleft()` - Returns the amount of time remaining until the round completes, in ticks.

`mugen.matchno()` - Returns the value of the `MatchNo` trigger.

`mugen.roundno()` - Returns the value of the `RoundNo` trigger.

`mugen.forceplayersintostand()` - Forces all non-Helper players into Stand state (state 0, with 0/0 velocity).

`mugen.toggleplayerai(i)` - Toggles AI for player with index `i`. Note this is a player index, not player ID (so setting `i` = 1 will affect player 1).

`mugen.toggleclsndisplay()` - Toggles display of CLSN boxes. Cycles similarly to CTRL+C (wireframe, colored, hidden).

`mugen.toggletrainingmode()` - Toggles training mode on or off. (Note that once toggled on, it seems like the `roundtimemax` becomes infinite and does not return to normal after toggling off).

`mugen.toggleconsole()` - Toggles the Lua console open or closed.

`mugen.clipboardprint()` - Writes the input string `s` to the game clipboard (but not `mugen.log`).

`mugen.clearclipboards()` - Clears the game clipboard.

`mugen.killteam(i)` - Sets team `i`'s life to 0 (where `i` is 1 or 2). If `i` is ommitted, both team's life is set to 0.

`mugen.almostkillteam(i)` - Sets team `i`'s life to 1 (where `i` is 1 or 2). If `i` is ommitted, both team's life is set to 1.

`mugen.maxteampower(i)` - Sets team `i`'s power to maximum (where `i` is 1 or 2). If `i` is ommitted, both team's power is set to maximum.

`mugen.warning(s)` - Writes the input string `s` to the game clipboard (but not `mugen.log`). (Appears to be the same as `mugen.clipboardprint()` as there is no warning-specific messaging output).

`mugen.error(s)` - Throws an error with the provided input string `s` as a message. Will immediately terminate the currently-executing script (and may not display an error if uncaught).

`mugen.isinit` - Not a function. Boolean value representing whether or not Lua is initialized. (If this is ever `false`, something has gone incredibly wrong!)

## New Functionality

`mugen.getbaseaddress()` - Returns the base address of the MUGEN data structure. Not recommended to use unless you're planning to work with direct memory editing.

`mugen.gametimeset(i)` - Sets the value of the `GameTime` trigger.

`mugen.roundstateset(i)` - Sets the value of the `RoundState` trigger.

`mugen.matchnoset(i)` - Sets the value of the `MatchNo` trigger.

`mugen.roundnoset(i)` - Sets the value of the `MatchNo` trigger.

### AssertSpecial

Try `mugen.isassertxyz()` where `xyz` is the name of an AssertSpecial flag (in lowercase). To set, try `mugen.setassertxyz(i)` where `xyz` is the name of an AssertSpecial flag. The value you provide should fit into 1 byte (0 ~ 255, but only functional values are 0 and 1).

## Unknown or Unconfirmed

`mugen.winningteam()` - Presumed to return the team which won the current round, but unconfirmed. Returned `0` in my tests.

`mugen.togglemaxpowermode()` - Is this the same as `mugen.maxteampower()` ommitting a team parameter?

`mugen.screenwidth()` - Appears to return the same value as `mugen.gamewidth()`, but may have some other purpose. Might be similar to the `ScreenWidth` trigger's interaction with `mugen.camerazoom()`.

`mugen.screenheight()` - Appears to return the same value as `mugen.gameheight()`, but may have some other purpose. Might be similar to the `ScreenHeight` trigger's interaction with `mugen.camerazoom()`.

`mugen.consoleprint(s)` - Assume this prints to the Lua console.

`mugen.lifereset()` - Appears to reset all three of Life, Power, Time but needs confirmation.

# Player Module

The `player` module exposes some functionality for working with individual players and exposes the values of many player-specific triggers. Most of the base functionality is for read-only access to triggers, so a lot of the expansion effort is focused on writing values to triggers.

A warning for these functions: I mention that many of them return the current value of a trigger - HOWEVER, some triggers which are treated as boolean (e.g. `InGuardDist`, `Ctrl`) may be returned as a proper boolean datatype in Lua - so you will not be able to operate with them as integers the same way you would in MUGEN. I'll mark which ones return boolean at some point in the future.

A note on syntax: as with Lua, I use the colon operator `:` here to indicate a function is being called on an object. If I use the dot operator `.`, it indicates a function can be called on the base `player` module, no object required.

## Original Functionality

`player.player_iter()` - Provides an iterator over all currently active players (including Helpers).

`player.interface_iter()` - Appears to provide an iterator over all the components of the `player` module?

`player.getplayer(idx)` - Returns a `player` object for the player with index `idx` (note this is the index ranging from 1 (player 1) to 60 (Helper 56), and not the ID).

`player.getplayerlist()` - Returns a list of all players. Appears to be a list of player indices and not player objects.

`player.playeridexist(id)` - Checks whether a player exists with the given ID.

`player.indexfromid(id)` - Returns the player index for a player with the given ID.

`player.indexisvalid(idx)` - Checks whether a player exists for the given player index.

`player.enabled(idx)` - Checks whether the player with index `idx` is enabled.

`player.enableset(idx, b)` - Sets the player with index `idx` as enabled or disabled.

`player:life()` - Returns the current value of the `Life` trigger.

`player:lifemax()` - Returns the current value of the `LifeMax` trigger.

`player:lifeset(i)` - Sets the `Life` value for the player to `i`.

`player:power()` - Returns the current value of the `Power` trigger.

`player:powermax()` - Returns the current value of the `PowerMax` trigger.

`player:powerset(i)` - Sets the `Power` value for the player to `i`.

`player:win()` - Returns the current value of the `Win` trigger.

`player:winperfect()` - Returns the current value of the `WinPerfect` trigger.

`player:winko()` - Returns the current value of the `WinKO` trigger.

`player:wintime()` - Returns the current value of the `WinTime` trigger.

`player:lose()` - Returns the current value of the `Lose` trigger.

`player:loseko()` - Returns the current value of the `LoseKO` trigger.

`player:losetime()` - Returns the current value of the `LoseTime` trigger.

`player:drawgame()` - Returns the current value of the `DrawGame` trigger.

`player:matchover()` - Returns the current value of the `MatchOver` trigger.

`player:animtime()` - Returns the current value of the `AnimTime` trigger.

`player:anim()` - Returns the current value of the `Anim` trigger.

`player:animelemno(i)` - Returns the current value of the `AnimElemNo` trigger, given index `i`.

`player:animelemtime(i)` - Returns the current value of the `AnimElemTime` trigger, given index `i`.

`player:animexist(i)` - Returns the current value of the `AnimExist` trigger, given index `i`.

`player:selfanimexist(i)` - Returns the current value of the `SelfAnimExist` trigger, given index `i`.

`player:roundsexisted()` - Returns the current value of the `RoundsExisted` trigger.

`player:teamside()` - Returns the current value of the `TeamSide` trigger.

`player:teammode()` - Returns the current value of the `TeamMode` trigger, as a string.

`player:ishometeam()` - Returns the current value of the `IsHomeTeam` trigger.

`player:alive()` - Returns the current value of the `Alive` trigger.

`player:aienabled()` - Returns a boolean indicating whether or not AI is enabled.

`player:ailevel()` - Returns the current value of the `AILevel` trigger.

`player:aienableset(b)` - Takes a boolean value and sets whether AI is currently enabled.

`player:hitcount()` - Returns the current value of the `HitCount` trigger.

`player:uniqhitcount()` - Returns the current value of the `UniqHitCount` trigger.

`player:movehit()` - Returns the current value of the `MoveHit` trigger.

`player:moveguarded()` - Returns the current value of the `MoveGuarded` trigger.

`player:movecontact()` - Returns the current value of the `MoveContact` trigger.

`player:movereversed()` - Returns the current value of the `MoveReversed` trigger.

`player:inguarddist()` - Returns the current value of the `InGuardDist` trigger.

`player:stateno()` - Returns the current value of the `StateNo` trigger.

`player:prevstateno()` - Returns the current value of the `PrevStateNo` trigger.

`player:statetype()` - Returns the current value of the `StateType` trigger, as a single character.

`player:movetype()` - Returns the current value of the `MoveType` trigger, as a single character.

`player:ctrl()` - Returns the current value of the `Ctrl` trigger.

`player:var(i)` - Returns the current value of the `var(i)` trigger.

`player:fvar(i)` - Returns the current value of the `fvar(i)` trigger.

`player:sysvar(i)` - Returns the current value of the `sysvar(i)` trigger.

`player:sysfvar(i)` - Returns the current value of the `sysfvar(i)` trigger.

`player:numproj()` - Returns the current value of the `NumProj` trigger.

`player:projcanceltime(i)` - Returns the current value of the `ProjCancelTime(i)` trigger.

`player:projhittime(i)` - Returns the current value of the `ProjHitTime(i)` trigger.

`player:projguardedtime(i)` - Returns the current value of the `ProjGuardedTime(i)` trigger.

`player:projcontacttime(i)` - Returns the current value of the `ProjContactTime(i)` trigger.

`player:name()` - Returns the current value of the `Name` trigger, as a string.

`player:authorname()` - Returns the current value of the `AuthorName` trigger, as a string.

`player:numpartner()` - Returns the current value of the `NumPartner` trigger.

`player:numenemy()` - Returns the current value of the `NumEnemy` trigger.

`player:id()` - Returns the current value of the `ID` trigger.

`player:facing()` - Returns the current value of the `Facing` trigger.

`player:hitfall()` - Returns the current value of the `HitFall` trigger.

`player:hitshakeover()` - Returns the current value of the `HitShakeOver` trigger.

`player:hitover()` - Returns the current value of the `HitOver` trigger.

`player:hitpausetime()` - Returns the current value of the `HitPauseTime` trigger.

`player:canrecover()` - Returns the current value of the `CanRecover` trigger.

`player:palno()` - Returns the current value of the `PalNo` trigger.

`player:numexplod()` - Returns the current value of the `NumExplod` trigger.

`player:numtarget()` - Returns the current value of the `NumTarget` trigger.

`player:ishelper()` - Returns the current value of the `IsHelper` trigger.

`player:numhelper(i)` - Returns the current value of the `NumHelper` trigger. Takes an optional integer argument to limit the count to only Helpers with the specified HelperID.

`player:isvalid()` - Returns an integer representing whether the player is valid or not (assume this is for managing Helpers being destroyed?)

`player:vel()` - Returns a table representing the `Vel` triggers. Table has components for `x`, `y`, `z` (e.g. `player:vel().y`).

`player:pos()` - Returns a table representing the `Pos` triggers. Table has components for `x`, `y`, `z` (e.g. `player:pos().y`).

`player:screenpos()` - Returns a table representing the `ScreenPos` triggers. Table has components for `x`, `y`, `z` (e.g. `player:screenpos().y`).

`player:hitvel()` - Returns a table representing the `HitVel` triggers. Table has components for `x`, `y`, `z` (e.g. `player:hitvel().y`).

`player:backedge()` - Returns the position of the back edge of the screen. May be the same as `mugen.leftedge` or `mugen.rightedge` depending on `player:facing`; unknown if it adjusts for localcoord.

`player:frontedge()` - Returns the position of the front edge of the screen. May be the same as `mugen.leftedge` or `mugen.rightedge` depending on `player:facing`; unknown if it adjusts for localcoord.

`player:backedgedist()` - Returns the current value of the `BackEdgeDist` trigger.

`player:frontedgedist()` - Returns the current value of the `FrontEdgeDist` trigger.

`player:backedgebodydist()` - Returns the current value of the `BackEdgeBodyDist` trigger.

`player:frontedgebodydist()` - Returns the current value of the `FrontEdgeBodyDist` trigger.

`player:const(s)` - Returns the value for the Const specified by the string `s`. For constants which specify more than one value (e.g. `velocity.run.back`), this will return a table with a similar format to `player:vel()`.

`player:gethitvar(s)` - Returns the value for the HitVar specified by the string `s`.

`player:velset(t)` - Applies the effects of a VelSet state controller. `t` is a table accepting named properties for the arguments applicable to a regular VelSet (i.e. x, y).

`player:changestate(t)` - Applies the effects of a ChangeState state controller. `t` is a table accepting named properties for the arguments applicable to a regular ChangeState (i.e. value, ctrl, anim).

`player:explod(t)` - Applies the effects of a Explod state controller. `t` is a table accepting named properties for the arguments applicable to a regular Explod (i.e. anim, ownpal, pos, id, .....).

## New Functionality

`player.playerfromid(id)` - Returns a player object for the player owning the given ID.

`player.current()` - Returns the player object which is currently running a Lua script. WARNING: THIS IS NOT GUARANTEED TO BE CORRECT IF YOU SPAWN BACKGROUNDED TASKS, RUN LUA OUTSIDE OF THE DTC ENVIRONMENT, ETC. THE DTC PATCH IS RESPONSIBLE FOR SETTING THIS CORRECTLY.

`player:parent()` - Returns the player object representing the parent of another player (or the same player if it has no parent).

`player:root()` - Returns the player object representing the root of another player (or the same player if it has no root).

`player:stateowner()` - Returns the player object representing the state owner of another player (or the same player if it is not custom stated).

`player:forcecustomstate(p, i1, i2)` - Forces the player object to enter a custom state. Custom state runs code from player object `p`'s files. Sets `StateNo` to `i1` and, optionally, sets `Time` to `i2`. If `i2` is ommitted, `Time` will be set to 0. Example: `player.playerfromid(57):forcecustomstate(player.current(), 1000)` - forces the player with PlayerID 57 into custom state 1000 from the current player's state files.

`player:getplayeraddress()` - Returns the base address of the player's data structure. Not recommended to use unless you're planning to work with direct memory editing.

`player:getinfoaddress()` - Returns the base address of the player's info structure. Not recommended to use unless you're planning to work with direct memory editing.

`player:displayname()` - Returns the player's display name, as a string.

`player:isfrozen()` - Returns the player's frozen status, as an integer (1 or 0).

`player:helpertype()` - Returns the player's helper type (e.g. 0 = Normal-type Helper). Note this value is only meaningful if `player:ishelper()` returns `true`.

`player:helperid()` - Returns the player's HelperID (or zero for non-Helpers).

`player:parentid()` - Returns the player's ParentID (or zero for non-Helpers).

`player:guardflag()` - Gets the value of the guard flag (which prevents the effect of `Target*` state controllers).

`player:nameset(s)` - Sets the player's internal name.

`player:displaynameset(s)` - Sets the player's display name.

`player:authornameset(s)` - Sets the player's author name.

`player:ishelperset(i)` - Sets the value of the `IsHelper` trigger (as an integer).

`player:isfrozenset(i)` - Sets the value of the player's frozen status (as an integer).

`player:aliveset(i)` - Sets the value of the `Alive` trigger (as an integer).

`player:timeset(i)` - Sets the value of the `Time` trigger.

`player:helperidset(i)` - Sets the value of the player's HelperID.

`player:parentidset(i)` - Sets the value of the player's ParentID.

`player:helpertypeset(i)` - Sets the value of the player's helper type.

`player:teamsideset(i)` - Sets the value of the `TeamSide` trigger. (This also has an impact on the player's team from AI, trigger, etc. perspectives)

`player:ailevelset(i)` - Sets the value of the `AILevel` trigger.

`player:guardflagset(i)` - Sets the value of the guard flag (which prevents the effect of `Target*` state controllers).

`player:hitcountset(i)` - Sets the value of the `HitCount` trigger.

`player:uniqhitcountset(i)` - Sets the value of the `UniqHitCount` trigger.

`player:hitpausetimeset(i)` - Sets the value of the `HitPauseTime` trigger.

`player:idset(i)` - Sets the value of the `ID` trigger.

`player:palnoset(i)` - Sets the value of the `PalNo` trigger.

`player:statenoset(i)` - Sets the value of the `StateNo` trigger.

`player:prevstatenoset(i)` - Sets the value of the `PrevStateNo` trigger.

`player:lifemaxset(i)` - Sets the value of the `LifeMax` trigger. Will not allow it to be set to 0 as this crashes the game.

`player:powermaxset(i)` - Sets the value of the `PowerMax` trigger. Will not allow it to be set to 0 as this crashes the game (TODO, validate this for PowerMax...)

`player:ctrlset(t)` - Applies the effects of a CtrlSet state controller. `t` is a table accepting named properties for the arguments applicable to a regular CtrlSet (i.e. value).

`player:varset(idx, value)` - Applies the effects of a VarSet state controller against the regular variable with index `idx`.

`player:fvarset(idx, value)` - Applies the effects of a VarSet state controller against the float variable with index `idx`.

`player:sysvarset(idx, value)` - Applies the effects of a VarSet state controller against the regular system variable with index `idx`.

`player:sysfvarset(idx, value)` - Applies the effects of a VarSet state controller against the float system variable with index `idx`.

## Unknown or Unconfirmed

`player:hitdefattrmatch(??)` - Don't even know the signature for this one. Very likely it does not work with current `player` wrapper. If you want to play with it and figure it out, try using `p.wrapped:hitdefattrmatch(...)` (where `p` is a player object).

`player:numexplod()` - Confirmed this worked with no arguments, but need to re-confirm if it can accept an argument to check for explods with a given ID. Similar for `NumProj`, `NumTarget`.

`player:command(??)` - Just untested, assume it would take some string input.

`player:warning(s)` - Perhaps the same as `mugen.warning(s)`?

`player:error(s)` - Perhaps the same as `mugen.error(s)`?

`player:unitsize()` - Returns a number. Purpose is unknown.

`player:rc()` - Used in `const`, appears to be some sort of internal interface.

`player:parentdist()` - Easy to guess the purpose, but I didn't have a test character using Helpers handy. (We can probably assume this follows the convention set by `vel`, `pos`, etc. with a table being returned).

`player:rootdist()` - Same as `player:parentdist()`

# MLL Module

MLL is the module used as a bridge between FFI (the raw C stuff) and Lua. It's intended to be used mostly by the bootstrap `elua` script, as well as the extended `player` and `mugen` modules, and less by the end user. However, the functionality is available if you need it.

`mll.VirtualProtect(lpAddress, dwSize, flNewProtect)` - Thin wrapper around Windows API VirtualProtect. Errors are handled internally, and the function returns a boolean indicating success or failure.

`mll.VirtualAlloc(dwSize, flProtect)` - Thin wrapper around Windows API VirtualProtect. Errors are handled internally, and the function returns either the address of the allocated memory, or NULL (check for 0).

`mll.MemoryMapFile(filepath, size, permissions)` - Maps a file into memory. `size` can be an estimate, does not need to be exact (though you should avoid overshooting too much if possible, or else risk allocation failure). `permissions` should be a value like `flProtect` from VirtualAlloc.

`mll.GetMugenVersion()` - Returns 1 for 1.1a4, 2 for 1.1b1.

`mll.ReadByte(addr)` - Reads one byte from `addr` and returns it.

`mll.ReadInteger(addr)` - Reads one int from `addr` and returns it.

`mll.ReadFloat(addr)` - Reads one float from `addr` and returns it.

`mll.ReadDouble(addr)` - Reads one double from `addr` and returns it.

`mll.ReadString(addr)` - Reads a null-terminated string from `addr` and returns it.

`mll.WriteByte(addr, val)` - Writes one byte to `addr`.

`mll.WriteInteger(addr, val)` - Writes one int to `addr`.

`mll.WriteFloat(addr, val)` - Writes one float to `addr`.

`mll.WriteDouble(addr, val)` - Writes one double to `addr`.

`mll.WriteString(addr, val)` - Writes a null-terminated string to `addr`.