.386
.MODEL flat, stdcall

.code

translate_asm_to_machine_code PROC,
	mnemonic: DWORD,
	target_addr: DWORD,
	source_addr: DWORD,
	result_addr: DWORD
	LOCAL digit: BYTE, encoded: BYTE

	; get opcode
	; a function call

	ret


translate_asm_to_machine_code ENDP

end
