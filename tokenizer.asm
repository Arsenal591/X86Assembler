.386
.MODEL flat, stdcall

include tokenizer.inc
include operand.inc
include parser_varible.inc
include functions.inc

Str_copy proto,
	source: PTR BYTE,
	target: PTR BYTE

Str_compare proto,
	string1: PTR BYTE,
	string2: PTR BYTE

WriteString proto
WriteChar proto
WriteInt proto

.data
divide_str BYTE "--------------", 13, 10, 0

reg_string_mappings RegStringMappingElem <"EAX", full_reg SHL 4 + EAX_num>
RegStringMappingElem <"EBX", full_reg SHL 4 + EBX_num>
RegStringMappingElem <"ECX", full_reg SHL 4 + ECX_num>
RegStringMappingElem <"EDX", full_reg SHL 4 + EDX_num>
RegStringMappingElem <"ESI", full_reg SHL 4 + ESI_num>
RegStringMappingElem <"EDI", full_reg SHL 4 + EDI_num>
RegStringMappingElem <"ESP", full_reg SHL 4 + ESP_num>
RegStringMappingElem <"EBP", full_reg SHL 4 + EBP_num>
RegStringMappingElem <"AX", half_reg SHL 4 + EAX_num>
RegStringMappingElem <"BX", half_reg SHL 4 + EBX_num>
RegStringMappingElem <"CX", half_reg SHL 4 + ECX_num>
RegStringMappingElem <"DX", half_reg SHL 4 + EDX_num>
RegStringMappingElem <"SI", half_reg SHL 4 + ESI_num>
RegStringMappingElem <"DI", half_reg SHL 4 + EDI_num>
RegStringMappingElem <"SP", half_reg SHL 4 + ESP_num>
RegStringMappingElem <"BP", half_reg SHL 4 + EBP_num>
RegStringMappingElem <"AL", low_quar_reg SHL 4 + EAX_num>
RegStringMappingElem <"BL", low_quar_reg SHL 4 + EBX_num>
RegStringMappingElem <"CL", low_quar_reg SHL 4 + ECX_num>
RegStringMappingElem <"DL", low_quar_reg SHL 4 + EDX_num>
RegStringMappingElem <"AH", high_quar_reg SHL 4 + EAX_num>
RegStringMappingElem <"BH", high_quar_reg SHL 4 + EBX_num>
RegStringMappingElem <"CH", high_quar_reg SHL 4 + ECX_num>
RegStringMappingElem <"DD", high_quar_reg SHL 4 + EDX_num>

.code

Str_clear PROC USES ecx edi,
	target: DWORD,
	max_length: DWORD

	mov ecx, 0
	mov edi, target

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

	lea edx, code_symbol_list
	invoke find_symbol, edx, pString
	.if ebx == 0
		mov eax, 1
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
	pOperand: DWORD

	lea edx, data_symbol_list
	invoke find_symbol, edx, pString
	.if ebx == 0
		mov eax, 1
		ret
	.else
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
	ret

process_data_label ENDP

process_proc_label PROC USES ebx edx esi,
	pString: DWORD,
	pOperand: DWORD,
	current_address: DWORD

	lea edx, proc_symbol_list
	invoke find_symbol, edx, pString
	.if ebx == 0
		mov eax, 1
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

process_proc_label ENDP

convert_symbol_to_operand PROC USES ecx edx esi,
	pString: DWORD,
	pOperand: DWORD,
	current_address: DWORD

	; check if it is register
	mov ecx, 0
	mov edx, offset reg_string_mappings
	.while ecx < 24
		lea esi, (RegStringMappingElem ptr[edx]).str1
		invoke Str_compare, pString, esi
		je L1
		inc ecx
		add edx, sizeof RegStringMappingElem
		.continue
		L1:
		.break
	.endw

	.if ecx < 24
		mov esi, pOperand
		mov (Operand ptr[esi]).op_type, reg_type
		.if ecx < 8
			mov (Operand ptr[esi]).op_size, 32
		.elseif ecx < 16
			mov (Operand ptr[esi]).op_size, 16
		.else
			mov (Operand ptr[esi]).op_size, 8
		.endif
		mov esi, (Operand ptr[esi]).address
		
		mov al, (RegStringMappingElem ptr[edx]).reg_num
		mov (RegOperand ptr[esi]).reg, al

		mov eax, 0
		ret
	.endif

	invoke process_data_label, pString, pOperand
	.if eax == 0
		ret
	.endif

	invoke process_code_label, pString, pOperand, current_address
	.if eax == 0
		ret
	.endif 

	invoke process_proc_label, pString, pOperand, current_address
	ret

convert_symbol_to_operand ENDP

insert_code_label PROC USES ebx,
	pString: DWORD,
	address: DWORD

	invoke find_symbol, offset code_symbol_list, pString
	.if ebx != 0
		mov eax, 1
		ret
	.else
		invoke push_list, offset code_symbol_list, pString, address, 0
		mov eax, 0
		ret
	.endif
	ret
insert_code_label ENDP

insert_proc_label PROC USES ebx,
	pString: DWORD,
	address: DWORD

	invoke find_symbol, offset proc_symbol_list, pString
	.if ebx != 0
		mov eax, 1
		ret
	.else
		invoke push_list, offset proc_symbol_list, pString, address, 0
		mov eax, 0
		ret
	.endif
	ret
insert_proc_label ENDP


tokenize_instruction PROC USES eax ecx edx esi edi,
	code: DWORD,
	max_length: DWORD,
	initial_address: DWORD,
	pCharProcessed: DWORD,
	pFinalAddress: DWORD
	LOCAL char: BYTE, status: BYTE, \
	      tmp_str[256]: BYTE, tmp_str_len: DWORD, \
		  instruct_str[256]: BYTE, \
		  nOperands: BYTE, \
		  operands[2]: Operand, real_operands[2]: LocalOperand, \
		  char_processed: DWORD
		  
	mov nOperands, 0
	mov status, BEGIN_STATE
	mov char_processed, 0
	mov tmp_str_len, 0
	
	lea esi, tmp_str
	invoke Str_clear, esi, 256
	lea esi, instruct_str
	invoke Str_clear, esi, 256

	mov ecx, 0
	mov esi, code
	.while ecx <= max_length
		mov al, BYTE PTR[esi]
		mov char, al
		inc char_processed

		push esi
		lea esi, tmp_str

		; dumps debug info
		push eax
		push edx
		mov edx, offset divide_str
		call WriteString
		movzx eax, status
		call WriteInt
		mov al, 13
		call WriteChar
		mov al, 10
		call WriteChar
		
		mov al, char
		call WriteChar
		mov al, 13
		call WriteChar
		mov al, 10
		call WriteChar	

		lea edx, tmp_str
		call WriteString
		mov al, 13
		call WriteChar
		mov al, 10
		call WriteChar
		mov al, 13
		call WriteChar
		mov al, 10
		call WriteChar
		
		pop edx
		pop eax

		; ends debug info
		.if status == BEGIN_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				mov status, FIRST_SYMBOL_STATE
				jmp increase_tmp_str	

			.elseif char == 13 || char == 10
				jmp final
			.elseif char == 0
				ret
			; else ERRORs
			.endif
		.elseif status == FIRST_SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			    || (char >= '0' && char <= '9')
				jmp increase_tmp_str

			.elseif char == ':'
				mov status, AFTER_CODE_LABEL_STATE
				jmp add_new_code_label
			.elseif char == ' '
				mov status, AFTER_FIRST_SYMBOL_STATE
			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				lea edi, instruct_str
				invoke Str_copy, esi, edi
				jmp form_instruction

			; else ERRORs
			.endif
		.elseif status == AFTER_FIRST_SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				mov status, SYMBOL_STATE
				lea edi, instruct_str
				invoke Str_copy, esi, edi
				jmp clear_tmp_str

			.elseif char >= '0' && char <= '9'
				mov status, DIGIT_STATE
				lea edi, instruct_str
				invoke Str_copy, esi, edi
				jmp clear_tmp_str

			.elseif char == '['
				mov status, LOCAL_STATE
				lea edi, instruct_str
				invoke Str_copy, esi, edi
				jmp clear_tmp_str

			.elseif char == ':'
				mov status, AFTER_CODE_LABEL_STATE
				jmp add_new_code_label

			.elseif char == ' '
				; do nothing
			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				lea edi, instruct_str
				invoke Str_copy, esi, edi
				jmp form_instruction

			; else ERRORs
			.endif
		.elseif status == AFTER_CODE_LABEL_STATE
			.if char == ' ' || char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp clear_tmp_str
			; else ERRORS
			.endif
		.elseif status == AFTER_OPERAND_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				mov status, SYMBOL_STATE
				jmp increase_tmp_str

			.elseif char >= '0' && char <= '9'
				mov status, DIGIT_STATE
				jmp increase_tmp_str

			.elseif char == '['
				mov status, LOCAL_STATE

			.elseif char == ' '
				; do nothing
			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp form_instruction
			; else ERRORs
			.endif
		.elseif status == DIGIT_STATE
			.if char >= '0' && char <= '9'
				jmp increase_tmp_str

			.elseif char == ' '
				mov status, AFTER_OPERAND_STATE
				jmp deal_with_digit

			.elseif char == 13 || char == 10  || char == 0
				mov status, BEGIN_STATE
				; deal with digit
				jmp deal_with_digit
			;else ERRORs
			.endif

		.elseif status == LOCAL_STATE
			.if char == ']'
				mov status, AFTER_OPERAND_STATE
				jmp deal_with_local

			.elseif char == 13 || char == 10 || char == 0
				; errors

			.else
				jmp increase_tmp_str
			.endif

		.elseif status == SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			    || (char >= '0' && char <= '9')
				jmp increase_tmp_str
			.elseif char == ' '
				mov status, AFTER_OPERAND_STATE
				jmp deal_with_symbol

			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp deal_with_symbol
			.endif

			; else ERRORs
		.endif
		jmp final

		increase_tmp_str:
			invoke Str_write_at, esi, tmp_str_len, char
			inc tmp_str_len
			jmp final

		clear_tmp_str:
			mov tmp_str_len, 0
			invoke Str_clear, esi, 256
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			   || (char >= '0' && char <= '9')
				jmp increase_tmp_str
			.else
				jmp final
			.endif
		
		add_new_code_label:
			invoke insert_code_label, esi, initial_address
			.if eax != 0
				;ERROR
			.else
				;nothing
			.endif
			jmp final

		deal_with_symbol:
			.if nOperands == 2
				;ERROR
			.else
				inc nOperands

			.endif

			.if char == 13 || char == 10
				jmp form_instruction
			.else
				jmp clear_tmp_str
			.endif

		deal_with_digit:
			.if char == 13 || char == 10
				jmp form_instruction
			.else
				jmp clear_tmp_str
			.endif

		deal_with_local:
			.if char == 13 || char == 10
				jmp form_instruction
			.else
				jmp clear_tmp_str
			.endif

		form_instruction:
			.if char == 0
				ret
			.else
				jmp clear_tmp_str
			.endif
		
		final:
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
