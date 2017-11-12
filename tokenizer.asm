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

Str_write_at PROC USES edx,
	target: DWORD,
	index: DWORD,
	value: BYTE

	mov edx, target
	add edx, index
	mov BYTE PTR[edx], value

	ret

Str_write_at ENDP

tokenize_instruction PROC USES ecx esi,
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
