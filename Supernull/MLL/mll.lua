---- mll.lua: library created for use by Lua-based 1.1 Supernull characters.
----          it exposes a variety of functions for arbitrary memory read/write, memory allocation and page protection modification, file management, etc.
----          this is achieved by loading some DLLs to provide FFI capabilities in Lua.

---- most functions exposed in mll are quite low-level (raw read/write of memory, some C library functions)
---- if you're not comfortable with raw memory access, you may be able to leverage the upgraded player and mugen modules instead, which expose a bunch of friendly functions wrapping some mll calls.

local MugenLuaLibrary = { TEMPLATE_VERSION = 11 }

-- BEGIN EXTERNAL MODULES

	-- https://stackoverflow.com/a/20460053
	function lastIndexOf(haystack, needle)
		--Set the third arg to false to allow pattern matching
		local found = haystack:reverse():find(needle:reverse(), nil, true)
		if found then
			return haystack:len() - needle:len() - found + 2 
		else
			return found
		end
	end

	-- extension modules only need to be loaded if the global template version is either not set, or set lower than our version.
	-- if we have the older template version, we should not even bother loading (newer versions are intentionally backwards compatible.)

	if _G.MLL_TEMPLATE_VERSION == nil or _G.MLL_TEMPLATE_VERSION < MugenLuaLibrary.TEMPLATE_VERSION then
		mugen.log(string.format("Loading extension libraries with template version %s.\n", MugenLuaLibrary.TEMPLATE_VERSION))

		-- get folder containing this file
		local sourcefile = debug.getinfo(1, "S").source
		local sourcefolder = string.sub(sourcefile, 2, lastIndexOf(sourcefile, "/"))
		-- 1.1b1 restricts package.path to be `data/?.lua`, but we can just add another load path here
		-- 99.9% of the time this is already done by elua file but no harm in doing it again...
		package.path = package.path .. ";./?.lua;./?"
		
		-- mugen module extension
		require(sourcefolder .. "mugen")
		-- player module wrapper
		require(sourcefolder .. "player")
		-- animation module
		require(sourcefolder .. "anim")
		-- state module
		require(sourcefolder .. "state")

		_G.MLL_TEMPLATE_VERSION = MugenLuaLibrary.TEMPLATE_VERSION
	else
		mugen.log(string.format("Refusing to load extension libraries with template version %s - version %s is already loaded!\n", MugenLuaLibrary.TEMPLATE_VERSION, _G.MLL_TEMPLATE_VERSION))
	end
-- END EXTERNAL MODULES

-- BEGIN CONSTANTS
	local NULL = 0x00
	local INVALID_HANDLE_VALUE = -1

	local GENERIC_READ = -2147483648
	local FILE_SHARE_READ = 0x01
-- END CONSTANTS

-- loads + initializes the base libraries (lua5.1 and ffi) which are required for exploit to succeed.
-- this also includes the initial cdef which loads Windows API functions through ffi.
function MugenLuaLibrary.LoadBaseLibraries(basefolder, lualib, ffilib)
	-- attempting to re-import the libraries seems to be OK, but redoing the `ffi.cdef` is a no-no
	if ffi ~= nil then
		mugen.log("FFI is already loaded, skipping LoadBaseLibraries step.\n")
		return
	end

	mugen.log("Loading exploit libraries " .. lualib .. " and " .. ffilib .. " from " .. basefolder .. '...\n')

	-- load the libraries based on input - this will load the appropriate Lua for Windows runtime, as well as the FFI library to enable execution of C functions from Lua.
	package.loadlib(basefolder .. lualib, "*")
	_G.ffi = package.loadlib(basefolder .. ffilib, "luaopen_ffi")()

	ffi.cdef[[
	typedef void* LPVOID;
	typedef unsigned long DWORD;
	typedef DWORD* PDWORD;
	typedef DWORD* LPDWORD;
	typedef void* PVOID;
	typedef PVOID HANDLE;
	typedef int BOOL;

	typedef const char* LPCSTR;

	BOOL VirtualProtect(LPVOID lpAddress, size_t dwSize, DWORD flNewProtect, PDWORD lpflOldProtect);
	LPVOID VirtualAlloc(LPVOID lpAddress, size_t dwSize, DWORD flAllocationType, DWORD flProtect);
	HANDLE CreateFileA(LPCSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, void *lpSecurityAttributes, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile);
	BOOL ReadFile(HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, void *lpOverlapped);
	]]
	
	mugen.log("Successfully loaded exploit libraries and registered C function definitions.\n\n")
end

-- thin wrapper for C library VirtualProtect, handles lpflOldProtect and GetLastError logging internally
-- returns true on success, false otherwise
function MugenLuaLibrary.VirtualProtect(lpAddress, dwSize, flNewProtect)
	local lpflOldProtect = ffi.new"int[1]"
	if ffi.C.VirtualProtect(lpAddress, dwSize, flNewProtect, lpflOldProtect) ~= 1 then
		mugen.log(string.format("Error encountered while attempting to VirtualProtect at address 0x%08x: errno %d\n", lpAddress, ffi.errno()))
		return false
	end
	mugen.log(string.format("Successfully ran VirtualProtect at address 0x%08x.\n", lpAddress))
	return true
end

-- thin wrapper for C library VirtualAlloc, handles GetLastError logging internally
-- returns an address on success, NULL on failure
function MugenLuaLibrary.VirtualAlloc(dwSize, flProtect)
	local memoryBuffer = ffi.C.VirtualAlloc(NULL, dwSize, 0x1000, flProtect);
	if memoryBuffer == NULL then
		mugen.log(string.format("Error encountered while attempting to allocate memory: errno %d\n", ffi.errno()))
		return NULL
	end
	mugen.log(string.format("Successfully allocated memory at address 0x%08x.\n", tonumber(memoryBuffer)))
	return tonumber(memoryBuffer)
end

-- maps an input file into memory using Windows API functions (CreateFileA, VirtualAlloc, ReadFile).
-- any errors encountered will be logged to the standard MUGEN log file.
-- returns an address on success, NULL on failure
function MugenLuaLibrary.MemoryMapFile(filepath, size, permissions)
	local fileHandle = ffi.C.CreateFileA(filepath, GENERIC_READ, FILE_SHARE_READ, NULL, 0x03, 0x80, NULL);
	if fileHandle == INVALID_HANDLE_VALUE then
		mugen.log(string.format("Error encountered while attempting to open a file handle for %s: errno %d\n", filepath, ffi.errno()))
		return NULL
	end
	mugen.log(string.format("Successfully opened a file handle for file %s.\n", filepath))

	local fileBuffer = ffi.C.VirtualAlloc(NULL, size, 0x1000, permissions);
	if fileBuffer == NULL then
		mugen.log(string.format("Error encountered while attempting to allocate memory: errno %d\n", ffi.errno()))
		return NULL
	end
	mugen.log("Successfully generated an executable buffer for file contents.\n")
	
	local lpNumberOfBytesRead = ffi.new"int[1]"
	if ffi.C.ReadFile(fileHandle, fileBuffer, size, lpNumberOfBytesRead, NULL) ~= 1 then
		mugen.log(string.format("Error encountered while attempting to load file contents into memory: errno %d\n", ffi.errno()))
		return NULL
	end
	mugen.log("Successfully loaded file contents into memory.\n")
	
	return tonumber(fileBuffer)
end

-- simple function to check the version of MUGEN.
-- returns 1 for 1.1a4, 2 for 1.1b1.
function MugenLuaLibrary.GetMugenVersion()
	if MugenLuaLibrary.ReadInteger(0x443BC5) == -1017226401 then return 1 end
	return 2
end

-- read a single byte from memory
function MugenLuaLibrary.ReadByte(address)
	local addressPointer = ffi.cast("char *", address)
	return addressPointer[0]
end

-- read a single integer from memory
function MugenLuaLibrary.ReadInteger(address)
	local addressPointer = ffi.cast("int *", address)
	return addressPointer[0]
end

-- read a single float from memory
function MugenLuaLibrary.ReadFloat(address)
	local addressPointer = ffi.cast("float *", address)
	return addressPointer[0]
end

-- read a single double from memory
function MugenLuaLibrary.ReadDouble(address)
	local addressPointer = ffi.cast("double *", address)
	return addressPointer[0]
end

-- read a string from memory
function MugenLuaLibrary.ReadString(address)
	local addressPointer = ffi.cast("char *", address)
	return ffi.string(addressPointer)
end

-- write a single byte to destination address
function MugenLuaLibrary.WriteByte(address, value)
	local addressPointer = ffi.cast("char *", address)
	addressPointer[0] = value
end

-- write a single integer to destination address
function MugenLuaLibrary.WriteInteger(address, value)
	local addressPointer = ffi.cast("int *", address)
	addressPointer[0] = value
end

-- write a single float to destination address
function MugenLuaLibrary.WriteFloat(address, value)
	local addressPointer = ffi.cast("float *", address)
	addressPointer[0] = value
end

-- write a single double to destination address
function MugenLuaLibrary.WriteDouble(address, value)
	local addressPointer = ffi.cast("double *", address)
	addressPointer[0] = value
end

-- write a string to destination address
function MugenLuaLibrary.WriteString(address, value)
	local addressPointer = ffi.cast("char *", address)
	ffi.copy(addressPointer, value)
end

return MugenLuaLibrary