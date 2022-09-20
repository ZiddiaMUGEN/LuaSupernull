local music = {lib = {}}
music.__index = music

-- load relevant driver functions.
ffi.cdef[[
    char* SDL_GetError();

    int Mix_HaltChannel(int channel);

    // music (single-channel)
    int Mix_HaltMusic();
    int Mix_PlayMusic(void *music, int loops);
    int Mix_FadeInMusic(void *music, int loops, int ms);
    void *Mix_LoadMUS(const char *file);
    void Mix_FreeMusic(void *music);

    // volume adjustments for music
    int Mix_GetMusicVolume(void *music);
    int Mix_VolumeMusic(int volume);
]]
music.lib.sdl_err = ffi.load("SDL.dll") -- this is just for SDL_GetError
music.lib.sdl = ffi.load("SDL_mixer.dll")
music.lib.resample = ffi.load("libresample.dll")

-- check if music is disabled globally
music.enabled = mll.ReadInteger(mugen.getbaseaddress() + 0x11E7C) ~= 0
-- channel count
music.channels = mll.ReadInteger(0x5044EC)
-- 1 = libresample, 2 = SDL
-- we load both of these, SDL_Mixer is still used even if libresample is selected in mugen.cfg (probably engine uses them for different things?)
music.driver = mll.ReadInteger(mugen.getbaseaddress() + 0x12920)

-- utility to read SDL errors
function music.GetSDLError()
    local err = music.lib.sdl_err.SDL_GetError()
    if err ~= ffi.NULL then
        return mll.ReadString(err)
    else
        return "unspecified error"
    end
end

-- stops sounds on the specified channel
function music.StopSound(channel)
    music.lib.sdl.Mix_HaltChannel(channel)
end

-- stops sounds on all channels (this will INCLUDE game sounds)
function music.StopAllSounds()
    music.lib.sdl.Mix_HaltChannel(-1)
end

-- gets volume of the currently-playing music
function music.GetMusicVolume()
    if music.playing ~= nil then return music.lib.sdl.Mix_GetMusicVolume(music.playing) else return 128 end
end

-- sets the volume of the currently-playing music
function music.SetMusicVolume(vol)
    music.lib.sdl.Mix_VolumeMusic(vol)
end

function music.StopMusic()
    if music.playing ~= nil then
        music.lib.sdl.Mix_HaltMusic()
        music.lib.sdl.Mix_FreeMusic(music.playing)
        music.playing = nil
    end
end

-- plays music from a file
function music.PlayMusic(file, loops)
    if loops == nil then loops = 0 end

    -- stop and free currently-playing music, if it exists
    if music.playing ~= nil then
        music.lib.sdl.Mix_HaltMusic()
        music.lib.sdl.Mix_FreeMusic(music.playing)
        music.playing = nil
    end

    -- load music from file
    local mus = music.lib.sdl.Mix_LoadMUS(file)
    if mus == ffi.NULL then
        mugen.log(string.format("Failed to load music: %s\n", music.GetSDLError()))
        return false
    end
    
    -- try to play music
    if music.lib.sdl.Mix_PlayMusic(mus, loops) == -1 then
        mugen.log(string.format("Failed to play music: %s\n", music.GetSDLError()))
        return false
    end

    music.playing = mus
    return true
end

-- plays music from a file
function music.PlayMusicWithFadeIn(file, loops, fade)
    if loops == nil then loops = 0 end

    -- stop and free currently-playing music, if it exists
    if music.playing ~= nil then
        music.lib.sdl.Mix_HaltMusic()
        music.lib.sdl.Mix_FreeMusic(music.playing)
        music.playing = nil
    end

    -- load music from file
    local mus = music.lib.sdl.Mix_LoadMUS(file)
    if mus == ffi.NULL then
        mugen.log(string.format("Failed to load music: %s\n", music.GetSDLError()))
        return false
    end
    
    -- try to play music
    if music.lib.sdl.Mix_FadeInMusic(mus, loops, fade) == -1 then
        mugen.log(string.format("Failed to play music: %s\n", music.GetSDLError()))
        return false
    end

    music.playing = mus
    return true
end

_G.music = music