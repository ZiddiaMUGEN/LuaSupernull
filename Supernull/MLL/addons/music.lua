if _G.music == nil then
    local music = {lib = {}}
    music.__index = music

    -- load relevant driver functions.
    ffi.cdef[[
        int Mix_HaltChannel(int channel);
    ]]
    music.lib.sdl = ffi.load("SDL_mixer.dll")
    music.lib.resample = ffi.load("libresample.dll")

    -- check if music is disabled globally
    music.enabled = mll.ReadInteger(mugen.getbaseaddress() + 0x11E7C) ~= 0
    -- channel count
    music.channels = mll.ReadInteger(0x5044EC)
    -- 1 = libresample, 2 = SDL
    -- we load both of these, SDL_Mixer is still used even if libresample is selected in mugen.cfg (probably engine uses them for different things?)
    music.driver = mll.ReadInteger(mugen.getbaseaddress() + 0x12920)

    -- stops sounds on the specified channel
    function music.StopSound(channel)
        music.lib.sdl.Mix_HaltChannel(channel)
    end

    -- stops sounds on all channels (this will INCLUDE game sounds)
    function music.StopAllSounds()
        music.lib.sdl.Mix_HaltChannel(-1)
    end

    _G.music = music
end