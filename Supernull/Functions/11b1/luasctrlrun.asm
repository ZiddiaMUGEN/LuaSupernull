;; EAX=sctrl ID, EDI=sctrl content
;; 1.1b1: entry point = 0x0044C0DD
[bits 32]
;; preserve the sctrl ID
push eax

;; put our character's ID into a Lua global variable
mov ecx,dword [ebp+4]
push ecx
mov ecx, dword [0x005040FC]
push ecx
mov ecx,0x004C55E0 ;; lua_pushinteger(L, ID)
call ecx 
add esp,0x08
push charid
push -10002
mov ecx, dword [0x005040FC]
push ecx
mov ecx, 0x004C5A70 ;; lua_setfield(L, LUA_GLOBALSINDEX, "charID")
call ecx
add esp,0x0C

;; restore the sctrl ID
pop eax

;; handle custom elems
cmp eax,0x161
je .lua_asstring
cmp eax,0x162
je .lua_asfile

;; invalid elem
push 0x004F8820
mov eax,0x0044C0E2
jmp eax

.lua_asstring:
;; get the string to be executed
mov eax,dword [edi + 0x60]
lea eax,dword [eax + 0x38]
;; call the string loading function
push eax
mov ecx,dword [0x005040FC]
push ecx
mov ecx, 0x004C64A0 ;; luaL_loadstring
call ecx
add esp,0x08
test eax,eax
jnz .error

;; call the execution function
mov ecx,dword [0x005040FC]
push 0
push 0
push 0
push ecx
mov ecx, 0x004C5D50 ;; lua_pcall
call ecx
;; cleanup+test for errors
add esp,0x10
test eax,eax
jnz .error

jmp .done

.lua_asfile:
;; get the path to be executed
mov eax,dword [edi + 0x60]
lea eax,dword [eax + 0x38]

;; check if the player has been custom stated
;; read the stateowner index, which will be -1 if not custom stated
mov ecx, dword [ebp + 0xCB8]
cmp ecx, -1
je .not_custom_stated
;; read the info pointer of the state owner
mov edx, dword [0x5040E8]
lea edx, dword [edx + 0x12274 + ecx * 0x04]
mov edx, dword [edx]
mov ecx, dword [edx]
push ecx
jmp .read_folder

.not_custom_stated:
push dword [ebp]
mov ecx, dword [ebp]

.read_folder:
;; fetch the character folder string
mov ecx, dword [ecx+0xB0]
xor esi,esi
;; copy the input string to the character folder string
.loopfindend:
cmp byte [ecx], 0x00
je .loopfindenddone
inc ecx
inc esi
jmp .loopfindend

.loopfindenddone:
;; eax points at the file to be loaded
.loopcopy:
mov dl, byte [eax]
mov byte [ecx], dl
inc eax
inc ecx
cmp byte [eax], 0x00
je .loopcopydone
jmp .loopcopy

.loopcopydone:
mov byte [ecx], 0x00
;; call the file loading function
pop ecx
mov ecx, dword [ecx+0xB0]
push ecx
mov ecx,dword [0x005040FC]
push ecx
mov ecx, 0x004C6860 ;; luaL_loadfile
call ecx
;; cleanup+test for errors
lea ecx,[esp+0x04]
mov ecx, dword [ecx]
add ecx, esi
mov byte [ecx], 0x00
add esp,0x08
test eax,eax
jnz .error

;; call the execution function
mov ecx,dword [0x005040FC]
push 0
push 0
push 0
push ecx
mov ecx, 0x004C5D50 ;; lua_pcall
call ecx
;; cleanup+test for errors
add esp,0x10
test eax,eax
jnz .error

jmp .done

.error:
push 0x00
push -1
mov ecx,dword [0x005040FC]
push ecx
mov ecx, 0x004C53D0 ;; lua_tolstring
call ecx
add esp,0x0C
push eax
mov eax,dword [edi + 0x60]
lea eax,[eax + 0x38]
push eax
push errmsg
mov ecx, 0x0040C4A0 ;; mugen error handler (clipboard print)
call ecx
add esp,0x0C

.done:
mov eax,0x0044C0F1
jmp eax

errmsg db "Error while executing Lua from %s: %s.", 0x0D, 0x0A, 0x00
charid db "CurrCharacterID", 0x00