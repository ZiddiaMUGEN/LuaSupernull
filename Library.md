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

`mugen.helpermax()` - Returns the HelperMax value defined in mugen.cfg.

`mugen.helperexist()` - Returns the number of helpers which currently exist.

`mugen.explodmax()` - Returns the ExplodMax value defined in mugen.cfg.

`mugen.stagename()` - Returns the `name` parameter for the stage.

`mugen.stagedisplayname()` - Returns the `displayname` parameter for the stage.

`mugen.stageauthorname()` - Returns the `authorname` parameter for the stage.

`mugen.stagefile()` - Returns the relative path to the stage DEF file.

`mugen.wincount(i)` - Returns the wincount for team `i`, where `i` is either 1 or 2.

`mugen.winset(i, t, p)` - Sets the win flag for team `i`, where `i` is either 1 or 2. `t` is an optional parameter determining the win type, which will determine rendering for the win icon, and defaults to 0 (win by Normal). `p` is an optional parameter determining the winperfect status, and should be set to `true` or `false`.
    Valid values for `t` range from 0 to 7: 0 = win by normal, 1 = win by special, 2 = win by hyper, 3 = win by cheese, 4 = timeup, 5 = win by throw, 6 = win by suicide, 7 = killed by teammate

`mugen.wintypeset(r, t, v)` - Sets the win type for the round specified by `r` and the team specified by `t`. `r` should be a number between 1 and 10, and `t` should be either 1 or 2. `v` is the value to set for the win type.

`mugen.winperfectset(r, t, v)` - Sets the winperfect flag for the round specified by `r` and the team specified by `t`. `r` should be a number between 1 and 10, and `t` should be either 1 or 2. `v` is a boolean `true` or `false` determining the winperfect status.

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

`player:explod(t)` - Applies the effects of a Explod state controller. `t` is a table accepting named properties for the arguments applicable to a regular Explod (i.e. anim, ownpal, pos, id, .....). Parameters such as `pos`, `vel`, and `scale` which specify multiple subproperties can be defined either as subtables (e.g. `vel = { x = 1.0, y = 1.0 }`) or as Vector types (e.g. `vel = Vector:vec2(1.0, 1.0)`).

## New Functionality

`player.playerfromid(id)` - Returns a player object for the player owning the given ID.

`player.current()` - Returns the player object which is currently running a Lua script. WARNING: THIS IS NOT GUARANTEED TO BE CORRECT IF YOU SPAWN BACKGROUNDED TASKS, RUN LUA OUTSIDE OF THE DTC ENVIRONMENT, ETC. THE DTC PATCH IS RESPONSIBLE FOR SETTING THIS CORRECTLY.

`player:animations()` - Returns an iterator over all animations the player owns, as `anim` objects.

`player:anim(i)` - Returns an `anim` object representing the animation with action number `i` (or `nil`, if the action does not exist).

`player:states()` - Returns an iterator over all states the player owns, as `state` objects.

`player:state(i)` - Returns a `state` object representing the state with statedef number `i` (or `nil`, if the state does not exist).

`player:animcount()` - Returns the number of animations owned by the player.

`player:partner()` - Returns the player object representing the partner of another player. Returns the root's partner for a Helper. Returns `nil` if no partner exists.

`player:parent()` - Returns the player object representing the parent of another player (or the same player if it has no parent).

`player:root()` - Returns the player object representing the root of another player (or the same player if it has no root).

`player:enemy(i)` - Returns the `i`th enemy as a player object, or `nil` if there is no enemy. If you omit `i` it will return the first enemy.

`player:stateowner()` - Returns the player object representing the state owner of another player (or the same player if it is not custom stated).

`player:forcecustomstate(p, i1, i2)` - Forces the player object to enter a custom state. Custom state runs code from player object `p`'s files. Sets `StateNo` to `i1` and, optionally, sets `Time` to `i2`. If `i2` is ommitted, `Time` will be set to 0. Example: `player.playerfromid(57):forcecustomstate(player.current(), 1000)` - forces the player with PlayerID 57 into custom state 1000 from the current player's state files.

`player:getplayeraddress()` - Returns the base address of the player's data structure. Not recommended to use unless you're planning to work with direct memory editing.

`player:getinfoaddress()` - Returns the base address of the player's info structure. Not recommended to use unless you're planning to work with direct memory editing.

`player:getfolder()` - Returns the folder containing the character's DEF file, relative to mugen.exe.

`player:getexplod(id)` - Returns an `explod` object representing the first explod with ID `id`.

`player:getexplods(id)` - Returns an iterator over `explod` objects with ID `id`. If `id` is not provided this will return an iterator over every `explod` owner by this player.

`player:displayname()` - Returns the player's display name, as a string.

`player:isfrozen()` - Returns the player's frozen status, as an integer (1 or 0).

`player:localcoord()` - Returns a table containing the player's localcoord. Table contains fields `x` and `y`.

`player:time()` - Returns the value of the `Time` trigger.

`player:animno()` - Returns the current value of the `Anim` trigger.

`player:helpertype()` - Returns the player's helper type (e.g. 0 = Normal-type Helper). Note this value is only meaningful if `player:ishelper()` returns `true`.

`player:helperid()` - Returns the player's HelperID (or zero for non-Helpers).

`player:parentid()` - Returns the player's ParentID (or zero for non-Helpers).

`player:guardflag()` - Gets the value of the guard flag (which prevents the effect of `Target*` state controllers).

`player:stateno()` - Returns the value of the `StateNo` trigger.

`player:prevstateno()` - Returns the value of the `PrevStateNo` trigger.

`player:facing()` - Returns the value of the `Facing` trigger.

`player:movecontact()` - Returns the value of the `MoveContact` trigger.

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

`player:screenbound(t)` - Applies the effects of a ScreenBound state controller. `t` is a table accepting named properties for the arguments applicable to a regular ScreenBound (i.e. value, movecamera.x, movecamera.y). PLEASE NOTE that executing ScreenBound on a target player will not function correctly, as ScreenBound is reset at the start of each player's frame. You would need to patch the ScreenBound value reset via ASM to resolve this.

`player:getscreenbound()` - Returns a table with the current ScreenBound parameters applied to the player.

`player:selfstate(t)` - Applies the effects of a SelfState state controller. `t` is a table accepting named properties for the arguments applicable to a regular SelfState (i.e. value, anim, ctrl).

`player:posset(t)` - Applies the effects of a PosSet state controller. `t` is a table accepting named properties for the arguments applicable to a regular PosSet (i.e. x, y).

`player:velset(t)` - Applies the effects of a VelSet state controller. `t` is a table accepting named properties for the arguments applicable to a regular VelSet (i.e. x, y).

`player:velmul(t)` - Applies the effects of a VelMul state controller. `t` is a table accepting named properties for the arguments applicable to a regular VelMul (i.e. x, y).

`player:changeanim(t)` - Applies the effects of a ChangeAnim state controller. `t` is a table accepting named properties for the arguments applicable to a regular ChangeAnim (i.e. value, elem). Note that the `elem` parameter may not function correctly currently.

`player:trans(t)` - Applies the effects of a Trans state controller. `t` is a table accepting named properties for the arguments applicable to a regular Trans (i.e. trans, alpha). `alpha` should be a subtable with optional parameters `source`, `dest`.

`player:assertspecial(t)` - Applies the effects of an AssertSpecial state controller. `t` is a table accepting named properties for the arguments applicable to a regular AssertSpecial (i.e. flag, flag2, flag3).

`player:varset(idx, value)` - Applies the effects of a VarSet state controller against the regular variable with index `idx`.

`player:fvarset(idx, value)` - Applies the effects of a VarSet state controller against the float variable with index `idx`.

`player:sysvarset(idx, value)` - Applies the effects of a VarSet state controller against the regular system variable with index `idx`.

`player:sysfvarset(idx, value)` - Applies the effects of a VarSet state controller against the float system variable with index `idx`.

`player:scalefactor()` - Returns a scale factor between the player's localcoord and the screen co-ordinate system.

`player:animelemat(i)` - Return the `animation` structure representing the element at index `i`. (might be buggy?)

`player:target(i)` - Returns the `player` object representing this player's target. `i` is an optional index into the target list (defaults to 0).

`player:modifyexplod(t)` - Applies the effects of a ModifyExplod state controller. `t` is a table accepting named properties for the arguments applicable to a regular ModifyExplod. Supported parameters are `removetime`, `pos`, `vel`, `accel`, `scale`, `facing`, `vfacing`. Parameters such as `pos`, `vel`, and `scale` which specify multiple subproperties can be defined either as subtables (e.g. `vel = { x = 1.0, y = 1.0 }`) or as Vector types (e.g. `vel = Vector:vec2(1.0, 1.0)`).

`player:playmusic(f, t)` - Plays music from a file specified by `f`, with options specified by `t`. Only one sound can be played with `playmusic` at a time. `playmusic` is distinct from the `playsnd` state controller and is used to play music from standalone files stored on disk, rather than the SND file. Supported file formats depend on installed libraries (but WAV should work consistently). `t` is a table accepting any of the following options:
    - `loops` - the number of times to loop the music. Set to -1 to loop until stopped. Defaults to 0.
    - `volume` - the volume factor to apply to the music, between 0.0 and 1.0. If not provided, this music will re-use the volume factor from the previously played music.
    - `fade` - number of milliseconds to fade this music in for. If not specified, music will play at its intended maximum volume immediately.

`player:stopmusic()` - Stops the currently playing music, if any music is playing.

## Unknown or Unconfirmed

`player:hitdefattrmatch(??)` - Don't even know the signature for this one. Very likely it does not work with current `player` wrapper. If you want to play with it and figure it out, try using `p.wrapped:hitdefattrmatch(...)` (where `p` is a player object).

`player:numexplod()` - Confirmed this worked with no arguments, but need to re-confirm if it can accept an argument to check for explods with a given ID. Similar for `NumProj`, `NumTarget`.

`player:command(??)` - Just untested, assume it would take some string input.

`player:warning(s)` - Perhaps the same as `mugen.warning(s)`?

`player:error(s)` - Perhaps the same as `mugen.error(s)`?

`player:rc()` - Used in `const`, appears to be some sort of internal interface.

`player:parentdist()` - Easy to guess the purpose, but I didn't have a test character using Helpers handy. (We can probably assume this follows the convention set by `vel`, `pos`, etc. with a table being returned).

`player:rootdist()` - Same as `player:parentdist()`

# Explod Module

Explod module provides a way to work with explods owned by a given player. In order to reference an explod object, you should use `player:getexplod` or `player:getexplods`.

`explod:exists()` - Returns a boolean representing whether the explod is active or not.

`explod:id()` - ID property of the explod.

`explod:idset(i)` - Sets the ID property to `i`.

`explod:pos()` - pos property of the explod. Returns a subtable with `x` and `y` properties.

`explod:posset(t)` - Sets the random property. Input is a subtable with `x` and `y` properties.

`explod:vel()` - vel property of the explod. Returns a subtable with `x` and `y` properties.

`explod:velset(t)` - Sets the vel property. Input is a subtable with `x` and `y` properties.

`explod:accel()` - accel property of the explod. Returns a subtable with `x` and `y` properties.

`explod:accelset(t)` - Sets the accel property. Input is a subtable with `x` and `y` properties.

`explod:sprpriority()` - sprpriority property of the explod.

`explod:sprpriorityset(i)` - Sets the sprpriority property to `i`.

`explod:random()` - random property of the explod. Returns a subtable with `x` and `y` properties.

`explod:randomset(t)` - Sets the random property. Input is a subtable with `x` and `y` properties.

`explod:pausemovetime()` - pausemovetime property of the explod.

`explod:pausemovetimeset(i)` - Sets the pausemovetime property to `i`.

`explod:supermovetime()` - supermovetime property of the explod.

`explod:supermovetimeset(i)` - Sets the supermovetime property to `i`.

`explod:removetime()` - removetime property of the explod.

`explod:removetimeset(i)` - Sets the removetime property to `i`.

`explod:scale()` - scale property of the explod. Returns a subtable with `x` and `y` properties.

`explod:scaleset(t)` - Sets the scale property. Input is a subtable with `x` and `y` properties.

`explod:angle()` - angle property of the explod.

`explod:angleset(d)` - Sets the angle property to `d`.

`explod:xangle()` - xangle property of the explod.

`explod:xangleset(d)` - Sets the xangle property to `d`.

`explod:yangle()` - yangle property of the explod.

`explod:yangleset(d)` - Sets the yangle property to `d`.

`explod:bindtime()` - bindtime property of the explod.

`explod:bindtimeset(i)` - Sets the bindtime property to `i`.

`explod:postype()` - postype property of the explod as an integer.

`explod:postypeset(i)` - Sets the postype property to `i`.

`explod:ontop()` - ontop property of the explod as an integer.

`explod:ontopset(i)` - Sets the ontop property to `i`.

`explod:facing()` - facing property of the explod.

`explod:facingset(i)` - Sets the facing property to `i`.

`explod:vfacing()` - vfacing property of the explod.

`explod:vfacingset(i)` - Sets the vfacing property to `i`.

`explod:space()` - space property of the explod as an integer.

`explod:spaceset(i)` - Sets the space property to `i`.

`explod:shadow()` - shadow property of the explod.

`explod:shadowset(i)` - Sets the shadow property to `i`.

`explod:removeongethit()` - removeongethit property of the explod.

`explod:removeongethitset(i)` - Sets the removeongethit property to `i`.

`explod:ignorehitpause()` - ignorehitpause property of the explod.

`explod:ignorehitpauseset(i)` - Sets the ignorehitpause property to `i`.

`explod:trans()` - trans property of the explod as an integer.

`explod:transset(i)` - Sets the trans property to `i`.

`explod:alpha()` - alpha property of the explod. Returns a subtable with `src` and `dst` properties.

`explod:alphaset(t)` - Sets the alpha property. Input is a subtable with `src` and `dst` properties.

# State Module

State module is a new module introduced to help explore and interface with character state data. In order to reference a state object, you should use `player:state` or `player:states`.

## state

state submodule is used to represent a single statedef.

`state:stateno()` - Returns the state number.

`state:statetype()` - Returns a number representing the type of the state.

`state:movetype()` - Returns a number representing the movetype of the state.

`state:physics()` - Returns a number representing the physics of the state.

`state:juggle()` - Returns the amount of juggle points the state requires, as a `trigger` object.

`state:animid()` - Returns the animation the player changes to upon entering the state, as a `trigger` object.

`state:xvel()` - Returns the x component of the state's entry velocity, as a `trigger` object.

`state:yvel()` - Returns the y component of the state's entry velocity, as a `trigger` object.

`state:poweradd()` - Returns the amount of power the player gains upon entering the state, as a `trigger` object.

`state:controller(i)` - Returns the `controller` object for the given index.

`state:controllers()` - Returns an iterator over `controller` objects.

## controller

controller submodule is used to represent a single state controller.

`controller:triggercount()` - Returns the number of triggers applied to this controller (note: number of trigger conditions and not trigger lines; 5x `trigger1` will still only count as 1 for `triggercount`)

`controller:persistent()` - Returns the value of `persistent` for this controller. Note that this returns an integer. MUGEN also uses an integer to store `persistent`, but only uses the lowest byte for processing. Consider using `controller:persistent() % 256` if you need the value used during processing.

`controller:ignorehitpause()` - Returns the value of `ignorehitpause` for this controller. Note that this returns an integer. MUGEN also uses an integer to store `ignorehitpause`, but treats it as a boolean.

`controller:type()` - Returns a byte representing the state controller type.

`controller:properties()` - Returns a table containing properties specific to this controller type. Each value in the table is a `trigger` object.

## trigger

trigger submodule is used to represent a trigger or a trigger-like value (ex. when an expression is used as a parameter, this is treated as a trigger).

`trigger:isconstant()` - Returns a boolean indicating whether the trigger's value is constant.

`trigger:constant()` - Returns the constant value of the trigger. If the trigger is not constant, returns 0.

# Anim Module

Anim module is a new module introduced to help explore and interface with character animations. In order to reference an anim object, you should use `player:anim` or `player:animations`.

## anim

anim submodule is used to represent a single animation.

`anim:id()` - Returns the action number of this animation.

`anim:index()` - Returns the index of this animation.

`anim:elementcount()` - Returns the number of elements in the animation.

`anim:length()` - Returns the total length of the animation, in frames.

`anim:hasloop()` - Returns a boolean indicating if the animation has a loop.

`anim:loop()` - Returns a table with elements `frame`, `element` indicating the frame and animation element loop begins on.

`anim:element(i)` - Returns the `element` object for the provided index (or `nil` if no such element exists).

`anim:elements()` - returns an iterator over all of the animation's elements.

## element

element submodule is used to represent a single animation element.

`element:length()` - returns the number of frames this element lasts.

`element:hasclsn1()` - returns a boolean indicating if this element contains a CLSN1 box (including default boxes).

`element:hasclsn2()` - returns a boolean indicating if this element contains a CLSN2 box (including default boxes).

`element:clsn1count()` - returns the number of CLSN1 boxes in the element (including default boxes).

`element:clsn2count()` - returns the number of CLSN2 boxes in the element (including default boxes).

Note: for the below iterators, the parameters defining the CLSN boxes are screen co-ordinates, and may not match the values defined in the AIR file. To recover the number from the AIR file, you must divide the co-ordinates by `player:scalefactor()`.

`element:clsn1()` - returns an iterator over all CLSN1 boxes in the element. A CLSN1 box is a table defined with parameters `top`, `bottom`, `left`, and `right`.

`element:clsn2()` - returns an iterator over all CLSN2 boxes in the element. A CLSN2 box is a table defined with parameters `top`, `bottom`, `left`, and `right`.

`element:start()` - returns the frame on which this element starts being displayed.

## animmanager

animmanager submodule is used internally to help read and identify animations. It's generally not intended for direct use (you can use wrapper functions from `player` instead).

`animmanager:new(p)` - instantiate an animmanager instance. `p` should be the player whose animations you want to work with.

`animmanager:count()` - returns the total number of animations this player owns.

`animmanager:iterator()` - returns an iterator over all of the player's animations. 

`animmanager:animfromid(i)` - returns the `anim` object whose action number matches `i`.

# Music Module

Music module provides an interface for working with the sound libraries used by MUGEN.

`music.StopSound(i)` - Stops the sound playing on channel `i`.

`music.StopAllSounds()` - Stops sounds playing on all channels.

`music.SetMusicVolume(i)` - Sets the current music volume to `i`. Note volume in the sound library is an integer between 0 and 128.

`music.GetMusicVolume()` - Returns the current music volume.

`music.PlayMusic(f, i)` - Plays music from the file specified by `f` for `i` loops. If `i` is set to -1, the music will loop indefinitely until stopped.

`music.PlayMusicWithFadeIn(f, i, ms)` - Plays music from the file specified by `f` for `i` loops. If `i` is set to -1, the music will loop indefinitely until stopped. `ms` specifies the number of milliseconds to spend fading in to the current music volume.

`music.StopMusic()` - Stops the currently playing music, if any music is playing.

`music.GetSDLError()` - Utility function used internally to fetch the last error returned by the backing sound library.

# Hooks Module

Documentation around Hooks (an event system for MUGEN) is separated into `Hooks.md` as I anticipate it being a fairly large subsystem.

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