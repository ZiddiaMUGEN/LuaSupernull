;; ECX=sctrl string
;; 1.1a4: entry point = 0x004480A5
;; 1.1a4: stricmp = [0x004DE1FC]
[bits 32]
;; compare the input to the LuaExec state controller string
lea ecx,dword [esp+0x20]
push ecx
push luaexec
call dword [0x004DE1FC]
add esp,0x08
;; if equal, read value as a string
test eax,eax
je .lua_string

;; compare the input to the LuaFile state controller string
lea ecx,dword [esp+0x20]
push ecx
push luafile
call dword [0x004DE1FC]
add esp,0x08
;; if equal, read value as file
test eax,eax
je .lua_file

;; if neither matched, sctrl is invalid
lea ecx,dword [esp+0x20]
push ecx
push 0x004F8240 ;; "Not a valid elem type: %s"
mov eax,0x004480AB
jmp eax ;; continue with error handler

.lua_string:
push 0x161
jmp .lua_readparam

.lua_file:
push 0x162

.lua_readparam:
push luastring
push ebp
mov eax,0x0046A090 ;; this function finds the address for the start of the input string
call eax
add esp,0x08
test eax,eax ;; on error, the lua property does not exist - custom error handler
jnz .lua_parseparam
;; error handler
pop eax
lea eax,[esp+0x20]
push eax
push luamissing
mov eax,0x004480EF
jmp eax

.lua_parseparam:
push eax
mov eax,0x0045A9E0 ;; this function interprets the input string as a format string (re-uses the DtC processing here) -- in the future, might be better if this was done differently
call eax
add esp,0x04
test eax,eax ;; on error, there may be an issue with the input string - pass to regular DtC error handler
jnz .lua_storeparam
;; error handler
pop eax
mov eax,0x00444A9E
jmp eax

.lua_storeparam:
mov dword [ebx + 0x60],eax ;; store the string in the state controller structure
pop eax
mov dword [ebx + 0x10],eax ;; store the state controller ID in the state controller structure
mov eax,0x00446D72 ;; return to sctrl processing
jmp eax

luaexec db "LuaExec", 0x00
luafile db "LuaFile", 0x00
luamissing db "lua property not specified for %s.", 0x0D, 0x0A, 0x00
luastring db "lua", 0x00