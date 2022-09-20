[bits 32]

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

;; push the string to be executed
push hookstr
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

.error:
push 0x00
push -1
mov ecx,dword [0x005040FC]
push ecx
mov ecx, 0x004C53D0 ;; lua_tolstring
call ecx
add esp,0x0C
push eax
push errmsg
mov ecx, 0x0040C4A0 ;; mugen error handler (clipboard print)
call ecx
add esp,0x08

.done:
mov eax,dword [esp + 0x10]
pop edi
pop esi
pop ebp
pop ebx
add esp,0x18
ret

hookstr db "hooks.RunHook(hooks.OnPlayerStateExecutionOver, { target = player.current() })", 0x00
errmsg db "Error while executing hooks through Lua: %s.", 0x0D, 0x0A, 0x00
charid db "CurrCharacterID", 0x00