.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
include operand.inc
include instruction_table.inc
includelib Irvine32.lib

.code
;--------------------------------------------------
find_opcode PROC USES ebx ecx edx edi esi,
	mne_addr: PTR BYTE,			; the start address of a string, which is mnemonic
	op1_addr: PTR Operand,		; the first operand, null_ptr if no operand
	op2_addr: PTR Operand,		; the second operand, null_ptr if no operand
	encoded_addr: PTR BYTE,		; the return encoded value (e.g. +rb...)
	digit_addr: PTR BYTE		; the return /digit value
;
; Get the Opcode by mnemonic and operands
; Return: al = Opcode
;--------------------------------------------------
	mov ecx, table_mapping.len
	mov edi, table_mapping.address
	INVOKE Str_ucase, mne_addr
L1:
	INVOKE Str_compare, mne_addr, edi
	JE L2
	add edi, TYPE TableMappingElem
	loop L1
	; Not find in table mapping
	mov eax, 0
	ret
L2: ; Find in table mapping
	mov esi, DWORD PTR [edi + 8]
	mov ecx, DWORD PTR [esi]
	mov edi, DWORD PTR [esi + 4]
L3:
	mov dl, (TableElem PTR [edi]).target_type
	.IF op1_addr != 0
		mov esi, op1_addr
		mov bl, (Operand PTR [esi]).op_type
		.IF bl & dl
			mov bl, (Operand PTR [esi]).op_size
			mov dl, (TableElem PTR [edi]).target_size
			.IF bl != dl
				jmp L4
			.ENDIF
		.ELSE
			jmp L4
		.ENDIF
	.ELSE
		.IF dl != null_type
			jmp L4
		.ENDIF
	.ENDIF

	mov dl, (TableElem PTR [edi]).source_type
	.IF op2_addr != 0
		mov esi, op2_addr
		mov bl, (Operand PTR [esi]).op_type
		.IF bl & dl
			mov bl, (Operand PTR [esi]).op_size
			mov dl, (TableElem PTR [edi]).source_size
			.IF bl != dl
				jmp L4
			.ENDIF
		.ELSE
			jmp L4
		.ENDIF
	.ELSE
		.IF dl != null_type
			jmp L4
		.ENDIF
	.ENDIF
	
	jmp L5
L4:
	add edi, TYPE TableElem
	loop L3
	; Not find in table
	mov eax, 0
	ret
L5: ; Find in table
	mov al, (TableElem PTR [edi]).opcode
	
	mov bl, (TableElem PTR [edi]).encoded
	mov esi, encoded_addr
	mov BYTE PTR [esi], bl
	
	push edi
	.IF bl == 1
		mov edi, (Operand PTR [esi]).address
		add al, (RegOperand PTR [edi]).reg
	.ENDIF
	pop edi

	mov bl, (TableElem PTR [edi]).digit
	mov esi, digit_addr
	mov BYTE PTR [esi], bl
	ret
find_opcode ENDP
end find_opcode