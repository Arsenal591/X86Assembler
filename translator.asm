.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
include operand.inc
include instruction_table.inc
includelib Irvine32.lib

.code
;--------------------------------------------------
convert_byte_to_string PROC USES ebx ecx esi, 
	data: BYTE,
	result_addr: PTR BYTE
;--------------------------------------------------
	mov ecx, 2
	mov esi, result_addr
convert_byte:	
	mov bl, data
	and bl, 11110000b
	shr bl, 4
	.IF bl >= 10
		add bl, 55
	.ELSE
		add bl, 48
	.ENDIF
	mov [esi], bl
	inc esi
	shl data, 4
	loop convert_byte
	ret
convert_byte_to_string ENDP

;--------------------------------------------------
convert_dword_to_string PROC USES ebx ecx esi, 
	data: DWORD,
	result_addr: PTR BYTE
;--------------------------------------------------
	mov ecx, 8
	mov esi, result_addr
convert_dword:	
	mov ebx, data
	and ebx, 0F0000000h
	shr ebx, 28
	.IF bl >= 10
		add bl, 55
	.ELSE
		add bl, 48
	.ENDIF
	mov [esi], bl
	inc esi
	shl data, 4
	loop convert_dword
	ret
convert_dword_to_string ENDP

;--------------------------------------------------
append_space_to_string PROC USES ebx esi,
	result_addr: PTR BYTE
;--------------------------------------------------
	mov bl, 32
	mov esi, result_addr
	mov [esi], bl
	ret
append_space_to_string ENDP

;--------------------------------------------------
translate_asm_to_machine_code PROC USES ebx ecx edi esi,
	mne_addr: PTR BYTE,			; the start address of a string, which is mnemonic
	op1_addr: PTR Operand,		; the first operand, null_ptr if no operand
	op2_addr: PTR Operand,		; the second operand, null_ptr if no operand
	result_addr: PTR BYTE		; the machine code string
;
; Generate machine code from asm languange
; Return: eax = bytes of the machine code
;--------------------------------------------------
	LOCAL digit: BYTE, encoded: BYTE, 
		  mode_RM: BYTE, opcode: BYTE,
		  flag_displace: BYTE, displacement: SDWORD, 
		  flag_immediate: BYTE, immediate: SDWORD,
		  result_length: DWORD

	INVOKE find_opcode, mne_addr, op1_addr, op2_addr, ADDR digit, ADDR encoded
	mov opcode, al
	.IF encoded == 0
		INVOKE get_modeRM, op1_addr, op2_addr, digit
		mov mode_RM, al
	.ENDIF
	
	mov flag_displace, 0
	mov flag_immediate, 0
	
	.IF op1_addr == 0
		jmp generate_string
	.ENDIF

	mov esi, op1_addr
	mov bl, (Operand PTR [esi]).op_type
	.If (bl & mem_type) || (bl == offset_type) || (bl == imm_type)
		mov edi, (Operand PTR [esi]).address
		.IF bl == global_type
			mov flag_displace, 1
			mov ebx, (GlobalOperand PTR [edi]).value
			mov displacement, ebx
		.ELSEIF bl == local_type
			mov flag_displace, 1
			mov ebx, (LocalOperand PTR [edi]).bias
			mov displacement, ebx
		.ELSEIF bl == offset_type
			mov flag_displace, 1
			mov ebx, (OffsetOperand PTR [edi]).bias
			mov displacement, ebx
		.ELSE
			mov flag_immediate, 1
			mov ebx, (ImmOperand PTR [edi]).value
			mov immediate, ebx
		.ENDIF
	.ENDIF

	.IF op2_addr == 0
		jmp generate_string
	.ENDIF

	mov esi, op2_addr
	mov bl, (Operand PTR [esi]).op_type
	.If (bl & mem_type) || (bl == offset_type) || (bl == imm_type)
		mov edi, (Operand PTR [esi]).address
		.IF bl == global_type
			mov flag_displace, 1
			mov ebx, (GlobalOperand PTR [edi]).value
			mov displacement, ebx
		.ELSEIF bl == local_type
			mov flag_displace, 1
			mov ebx, (LocalOperand PTR [edi]).bias
			mov displacement, ebx
		.ELSEIF bl == offset_type
			mov flag_displace, 1
			mov ebx, (OffsetOperand PTR [edi]).bias
			mov displacement, ebx
		.ELSE
			mov flag_immediate, 1
			mov ebx, (ImmOperand PTR [edi]).value
			mov immediate, ebx
		.ENDIF
	.ENDIF

generate_string:
	mov esi, result_addr
	mov bl, opcode
	mov result_length, 0
	; Add Opcode
	INVOKE convert_byte_to_string, opcode, esi
	add esi, 2
	INVOKE append_space_to_string, esi
	inc esi
	; Add modR/M
	.IF encoded == 0
		INVOKE convert_byte_to_string, mode_RM, esi
		add esi, 2
		INVOKE append_space_to_string, esi
		inc esi
		add result_length, 3
	.ENDIF
	; Add displacement
	.IF flag_displace == 1
		.IF (displacement >= -128) && (displacement <= 127)
			mov ebx, displacement
			and ebx, 000000FFh
			INVOKE convert_byte_to_string, bl, esi
			add esi, 2
			INVOKE append_space_to_string, esi
			inc esi
			add result_length, 3
			jmp imm_string
		.ELSE
			INVOKE convert_dword_to_string, displacement, esi
			add esi, 8
			INVOKE append_space_to_string, esi
			inc esi
			add result_length, 9
			jmp imm_string
		.ENDIF
	.ENDIF

imm_string:	; Add immediate
	.IF flag_immediate == 1
		INVOKE convert_dword_to_string, immediate, esi
		add esi, 8
		INVOKE append_space_to_string, esi
		inc esi
		add result_length, 9
	.ENDIF
	mov eax, result_length
	ret
translate_asm_to_machine_code ENDP

end
	