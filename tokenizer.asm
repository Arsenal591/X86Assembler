.386
.MODEL flat, stdcall

include tokenizer.inc

.code

Str_clear PROC USES ecx edi,
	target: DWORD,
	max_length: DWORD

	mov ecx, 0
	lea edi, target

	.while ecx < max_length
		mov BYTE PTR[edi], 0
		inc ecx
		inc edi
	.endw
	ret

Str_clear ENDP

Str_write_at PROC USES eax edx,
	target: DWORD,
	index: DWORD,
	value: BYTE

	mov edx, target
	add edx, index
	mov al, value
	mov BYTE PTR[edx], al

	ret

Str_write_at ENDP

; return value in EAX
process_code_label PROC USES ebx edx esi,
	pString: DWORD,
	pOperand: DWORD,
	current_address: DWORD
	LOCAL pSymbolElem: DWORD, address_diff: SDWORD

	lea edx, code_symbol_list
	invoke find_symbol, edx, pString
	.if ebx == 0
		mov eax, -1
		ret
	.else
		mov esi, pOperand
		mov (Operand ptr[esi]).op_type, offset_type

		mov eax, (SymbolElem ptr[ebx]).address
		sub eax, current_address
		.if eax <= 127 || eax >= (1 SHL 32 - 128)
			mov (Operand ptr[esi]).op_size, 8
		.else
			mov (Operand ptr[esi]).op_size, 32
		.endif

		mov esi, (Operand ptr[esi]).address
		mov (OffsetOperand ptr[esi]).bias, eax

		mov eax, 0
	.endif
	ret

process_code_label ENDP

; return value in EAX
process_data_label PROC,
	pString: DWORD,
	pOperand: DWORD,

	lea edx, data_symbol_list
	invoke find_symbol, edx, pString
	.if ebx == 0
		mov eax, -1
		ret
	.elseif
		mov esi, pOperand
		mov (Operand ptr[esi]).op_type, global_type

		mov al, (SymbolElem ptr[ebx]).op_size
		mov (Operand ptr[esi]).op_size, al

		mov esi, (Operand ptr[esi]).address
		mov eax, (SymbolElem ptr[ebx]).address
		mov (GlobalOperand ptr[esi]).value, eax

		mov eax, 0
		ret
	.endif 

process_data_label ENDP

	code: DWORD,
	max_length: DWORD
	LOCAL char: BYTE, status: BYTE, tmp_str[256]: BYTE, tmp_str_len: DWORD

	mov status, BEGIN_STATE
	invoke Str_clear, tmp_str, 256
	mov tmp_str_len, 0

	mov ecx, 0
	lea esi, code
	.while ecx < max_length
		mov char, BYTE PTR[esi]
		push esi

		.if status == BEGIN_STATE
			if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				status = FIRST_SYMBOL_STATE
				; add char to symbol string
				lea esi, tmp_str
				invoke Str_write_at, esi, tmp_str_len
				inc tmp_str_len
			.elseif char == 13 || char == 10
				.continue
			; else ERRORs
			.endif
		.elseif status == FIRST_SYMBOL_STATE
			if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			    || (char >= '0' && char <= '9')
				; add char to symbol string
				lea esi, tmp_str
				invoke Str_write_at, esi, tmp_str_len
				inc tmp_str_len
			.elseif char == ':'
				mov status, AFTER_CODE_LABEL_STATE
				; deal with code label
			.elseif char == ' '
				mov status, AFTER_FIRST_SYMBOL_STATE
			.elseif char == 13 || char == 10
				; deal with insturction label without operands
			; else ERRORs
			.endif
		.elseif status == AFTER_FIRST_SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				; store symbol string as instruction
				; restore symbol string
			.elseif char >= '0' && char <= '9'
				; store symbol string as instruction
				; restore symbol string
			.elseif char == '['
				; store symbol string as instrction
				; restore symbol string
			.elseif char == ':'
				; deal with code label
			.elseif char == ' '
				; do nothing
			.elseif char == 13 || char == 10
				; deal with insturction label without operands
			; else ERRORs
			.endif
		.elseif status == AFTER_CODE_LABEL_STATE
			.if char == ' ' || char == 13 || char == 10
				mov status, BEGIN_STATE
			; else ERRORS
			.endif
		.elseif status == AFTER_OPERAND_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				; store symbol string as instruction
				; restore symbol string
			.elseif char >= '0' && char <= '9'
				; store symbol string as instruction
				; restore symbol string
			.elseif char == '['
				; store symbol string as instrction
				; restore symbol string
			.elseif char == ' '
				; do nothing
			.elseif char == 13 || char == 10
				; deal with insturction label without operands
			; else ERRORs
			.endif
		.elseif status == DIGIT_STATE
			.if char >= '0' && char <= '9'

			.elseif char == ' '

			.elseif char == 13 || char == 10

			;else ERRORs
			.endif

		.elseif status == LOCAL_STATE
			.if char == ']'

			.elseif char == 13 || char == 10
				; errors

			.else

			.endif

		.elseif status == SYMBOL_STATE
			if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			    || (char >= '0' && char <= '9')

			.elseif char == ' '

			.elseif char == 13 || char == 10

			; else ERRORs
		.endif


		pop esi
		inc ecx
		inc esi
	.endw

	ret


tokenize_instruction ENDP

tokenize_asm PROC,
	code: DWORD,
	max_length: DWORD


tokenize_asm ENDP

END
