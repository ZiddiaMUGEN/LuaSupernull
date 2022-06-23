Strongly recommend you don't rename these, not 100% sure how the dependencies will react if you try to rename them. 

lua5.1.dll provides the Lua for Windows runtime (technically this is already provided in MUGEN, but because Elecbyte baked the Lua source into the executable, it's not really accessible).
ffi.dll provides the Foreign Function Interface functionality (allowing declaration of C prototypes + calling Windows API functions directly from Lua).