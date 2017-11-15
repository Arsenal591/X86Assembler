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
convert_word_to_string PROC USES ebx ecx esi, 
	data: WORD,
	result_addr: PTR BYTE
;--------------------------------------------------
	mov ecx, 4
	mov esi, result_addr
convert_word:	
	mov bx, data
	and bx, 0F000h
	shr bx, 12
	.IF bl >= 10
		add bl, 55
	.ELSE
		add bl, 48
	.ENDIF
	mov [esi], bl
	inc esi
	shl data, 4
	loop convert_word
	ret
convert_word_to_string ENDP

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
translate_asm_to_machine_code PROC USES ebx ecx edx edi esi,
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
		  SIB: BYTE, has_SIB: BYTE,
		  flag_displace: BYTE, displacement: SDWORD, 
		  flag_immediate: BYTE, immediate: SDWORD,
		  digit_displace: BYTE, result_length: DWORD
	
	mov has_SIB, 0
	INVOKE find_opcode, mne_addr, op1_addr, op2_addr, ADDR digit, ADDR encoded
	mov opcode, al
	.IF encoded == 0 && op1_addr != 0
		INVOKE get_modeRM, op1_addr, op2_addr, digit
		mov mode_RM, al
		.IF ah == 0
			mov has_SIB, 0
		.ELSEIF
			mov has_SIB, 1
			push edx
			push eax
			mov edx, op1_addr
			mov al, (Operand ptr[edx]).op_type
			.IF al == local_type
				invoke get_SIB, edx
			.ELSEIF op2_addr != 0
				invoke get_SIB, op2_addr
			.ENDIF
			mov SIB, al
			pop eax
			pop edx
		.ENDIF
	.ENDIF
	
	mov flag_displace, 0
	mov digit_displace, 0
	mov flag_immediate, 0
	
	.IF op1_addr == 0
		jmp generate_string
	.ENDIF

	mov esi, op1_addr
	mov bl, (Operand PTR [esi]).op_type
	.IF (bl & mem_type) || (bl == offset_type) || (bl == imm_type)
		mov edi, (Operand PTR [esi]).address
		.IF bl == global_type
			mov flag_displace, bl
			mov edx, (GlobalOperand PTR [edi]).value
			mov displacement, edx
		.ELSEIF bl == local_type
			mov flag_displace, bl
			mov edx, (LocalOperand PTR [edi]).bias
			mov displacement, edx
		.ELSEIF bl == offset_type
			mov flag_displace, bl
			mov edx, (OffsetOperand PTR [edi]).bias
			mov displacement, edx
			mov dl, (Operand PTR [esi]).op_size
			mov digit_displace, dl
		.ELSE
			mov dl, (Operand PTR [esi]).op_size
			mov flag_immediate, dl
			mov edx, (ImmOperand PTR [edi]).value
			mov immediate, edx
		.ENDIF
	.ENDIF

	.IF op2_addr == 0
		jmp generate_string
	.ENDIF

	mov esi, op2_addr
	mov bl, (Operand PTR [esi]).op_type
	.IF (bl & mem_type) || (bl == offset_type) || (bl == imm_type)
		mov edi, (Operand PTR [esi]).address
		.IF bl == global_type
			mov flag_displace, bl
			mov edx, (GlobalOperand PTR [edi]).value
			mov displacement, edx
		.ELSEIF bl == local_type
			mov flag_displace, bl
			mov edx, (LocalOperand PTR [edi]).bias
			mov displacement, edx
		.ELSEIF bl == offset_type
			mov flag_displace, bl
			mov edx, (OffsetOperand PTR [edi]).bias
			mov displacement, edx
			mov dl, (Operand PTR [esi]).op_size
			mov digit_displace, dl
		.ELSE
			mov dl, (Operand PTR [esi]).op_size
			mov flag_immediate, dl
			mov edx, (ImmOperand PTR [edi]).value
			mov immediate, edx
		.ENDIF
	.ENDIF

generate_string:
	mov esi, result_addr
	mov result_length, 0
	; Add Opcode
	INVOKE convert_byte_to_string, opcode, esi
	add esi, 2
	add result_length, 2
	INVOKE append_space_to_string, esi
	inc esi
	; Add modR/M
	.IF op1_addr == 0
		jmp generate_end
	.ENDIF
	.IF encoded == 0
		.IF (op1_addr != 0) && (op2_addr == 0)
			mov edi, op1_addr
			mov bl, (Operand PTR [edi]).op_type
			.IF (bl == offset_type) || (bl == imm_type)
				jmp displacement_string
			.ENDIF
		.ENDIF
		INVOKE convert_byte_to_string, mode_RM, esi
		add esi, 2
		add result_length, 2
		INVOKE append_space_to_string, esi
		inc esi
	.ENDIF

SIB_string:
	.IF has_SIB == 0
		jmp displacement_string
	.ELSE
		INVOKE convert_byte_to_string, SIB, esi
		add esi, 2
		add result_length, 2
		INVOKE append_space_to_string, esi
		inc esi
	.ENDIF

displacement_string:
	; Add displacement
	.IF flag_displace == global_type
		INVOKE convert_dword_to_string, displacement, esi
		add esi, 8
		add result_length, 8
		INVOKE append_space_to_string, esi
		inc esi
		jmp imm_string
	.ELSEIF flag_displace == local_type
		.IF displacement == 0
			.IF mode_RM > 00111111b
				invoke convert_byte_to_string, 0, esi
				add esi, 2
				add result_length, 2
				INVOKE append_space_to_string, esi
				inc esi
				jmp imm_string
			.ENDIF
		.ELSEIF (displacement >= -128) && (displacement <= 127)
			mov ebx, displacement
			and ebx, 000000FFh
			INVOKE convert_byte_to_string, bl, esi
			add esi, 2
			add result_length, 2
			INVOKE append_space_to_string, esi
			inc esi
			jmp imm_string
		.ELSE
			INVOKE convert_dword_to_string, displacement, esi
			add esi, 8
			add result_length, 8
			INVOKE append_space_to_string, esi
			inc esi
			jmp imm_string
		.ENDIF
	.ELSEIF flag_displace == offset_type
		.IF digit_displace == 8
			mov ebx, displacement
			and ebx, 000000FFh
			INVOKE convert_byte_to_string, bl, esi
			add esi, 2
			add result_length, 2
			INVOKE append_space_to_string, esi
			inc esi
			jmp imm_string
		.ELSEIF digit_displace == 16
			mov ebx, displacement
			and ebx, 0000FFFFh
			INVOKE convert_word_to_string, bx, esi
			add esi, 4
			add result_length, 4
			INVOKE append_space_to_string, esi
			inc esi
			jmp imm_string
		.ELSEIF digit_displace == 32
			INVOKE convert_dword_to_string, displacement, esi
			add esi, 8
			add result_length, 8
			INVOKE append_space_to_string, esi
			inc esi
			jmp imm_string
		.ELSE
			jmp imm_string
		.ENDIF
	.ELSE
		jmp imm_string
	.ENDIF

imm_string:	; Add immediate
	.IF flag_immediate
		.IF flag_immediate == 8
			mov ebx, immediate
			and ebx, 000000FFh
			INVOKE convert_byte_to_string, bl, esi
			add esi, 2
			add result_length, 2
			INVOKE append_space_to_string, esi
			inc esi
			jmp generate_end
		.ELSEIF flag_immediate == 16
			mov ebx, immediate
			and ebx, 0000FFFFh
			INVOKE convert_word_to_string, bx, esi
			add esi, 4
			add result_length, 4
			INVOKE append_space_to_string, esi
			inc esi
			jmp generate_end
		.ELSEIF flag_immediate == 32
			INVOKE convert_dword_to_string, immediate, esi
			add esi, 8
			add result_length, 8
			INVOKE append_space_to_string, esi
			inc esi
			jmp generate_end
		.ELSE
			jmp generate_end
		.ENDIF
	.ENDIF

generate_end:	
	mov bl, 0
	mov [esi], bl
	shr result_length, 1
	mov eax, result_length
	ret
translate_asm_to_machine_code ENDP

end
	