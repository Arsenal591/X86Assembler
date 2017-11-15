.386
.MODEL flat, stdcall

include tokenizer.inc
include operand.inc
include parser_varible.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib

.data
start_proc_str BYTE "PROC", 0
end_proc_str BYTE "ENDP", 0
divide_str BYTE "--------------", 13, 10, 0
now_address BYTE "Address ", 0

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
RegStringMappingElem <"DH", high_quar_reg SHL 4 + EDX_num>

var_name BYTE 256 DUP(0)
var_type BYTE 16 DUP(0)

byte_name BYTE "BYTE", 0
word_name BYTE "WORD", 0
dword_name BYTE "DWORD", 0
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
		.if eax <= 129 || eax >= (1 SHL 32 - 126)
			mov (Operand ptr[esi]).op_size, 8
			sub eax, 2
			mov esi, (Operand ptr[esi]).address
			mov (OffsetOperand ptr[esi]).bias, eax
		.elseif eax <= 32770 || eax >= (1 SHL 32 - 32765)
			mov (Operand ptr[esi]).op_size, 16
			sub eax, 3
			mov esi, (Operand ptr[esi]).address
			mov (OffsetOperand ptr[esi]).bias, eax
		.else
			mov (Operand ptr[esi]).op_size, 32
			sub eax, 5
			mov esi, (Operand ptr[esi]).address
			mov (OffsetOperand ptr[esi]).bias, eax
		.endif

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
		.if eax <= 129 || eax >= (1 SHL 32 - 126)
			mov (Operand ptr[esi]).op_size, 8
			sub eax, 2
			mov esi, (Operand ptr[esi]).address
			mov (OffsetOperand ptr[esi]).bias, eax
		.elseif eax <= 32770 || eax >= (1 SHL 32 - 32765)
			mov (Operand ptr[esi]).op_size, 16
			sub eax, 3
			mov esi, (Operand ptr[esi]).address
			mov (OffsetOperand ptr[esi]).bias, eax
		.else
			mov (Operand ptr[esi]).op_size, 32
			sub eax, 5
			mov esi, (Operand ptr[esi]).address
			mov (OffsetOperand ptr[esi]).bias, eax
		.endif

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

convert_digit_to_operand PROC USES eax ecx edx,
	pString: DWORD,
	str_len: DWORD,
	pOperand: DWORD

	mov ecx, str_len
	mov edx, pString
	invoke ParseInteger32

	mov edx, pOperand
	mov (Operand ptr[edx]).op_type, imm_type
	.if eax < 128 || eax >= (1 SHL 32 - 128)
		mov (Operand ptr[edx]).op_size, 8
	.elseif eax <= 32767 || eax >= (1 SHL 32 - 32768)
		mov (Operand ptr[edx]).op_size, 16
	.else
		mov (Operand ptr[edx]).op_size, 32
	.endif

	mov edx, (Operand ptr[edx]).address
	mov (ImmOperand ptr[edx]).value, eax
	ret

convert_digit_to_operand ENDP

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

; todo: error handling
; todo: return pCharProcessed & pFinalAddress
tokenize_instruction PROC USES eax ebx ecx edx esi edi,
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
		  char_processed: DWORD, \
		  encoded_machine_code[256]: BYTE
		  
	mov nOperands, 0
	mov status, BEGIN_STATE
	mov char_processed, 0
	mov tmp_str_len, 0

	lea esi, real_operands[0]
	mov operands[0].address, esi
	lea esi, real_operands[sizeof LocalOperand]
	mov operands[sizeof Operand].address, esi
	
	lea esi, tmp_str
	invoke Str_clear, esi, 256
	lea esi, instruct_str
	invoke Str_clear, esi, 256
	lea esi, encoded_machine_code
	invoke Str_clear, esi, 256

	mov ecx, 0
	mov esi, code
	.while ecx <= max_length
		mov al, BYTE PTR[esi]
		mov char, al
		inc char_processed

		push esi
		lea esi, tmp_str

		COMMENT &
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

		&

		; ends debug info
		.if status == BEGIN_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				mov status, FIRST_SYMBOL_STATE
				jmp increase_tmp_str	

			.elseif char == 13 || char == 10
				jmp final
			.elseif char == 0
				jmp break_loop
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

			.elseif (char >= '0' && char <= '9') || char == '-' || char == '+'
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

			.elseif (char >= '0' && char <= '9') || char == '-' || char == '+'
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
			    ; if "ENDP" occurs, terminate the current proc
				invoke Str_compare, esi, offset end_proc_str
				je break_loop
				.if nOperands == 0
					push edx
					lea edx, operands[0]
					invoke convert_symbol_to_operand, esi, edx, initial_address
					pop edx
				.elseif nOperands == 1
					push edx
					lea edx, operands[sizeof Operand]
					invoke convert_symbol_to_operand, esi, edx, initial_address
					pop edx
				.endif
				
				.if eax != 0
					; ERRORs
				.else
					
				.endif
				inc nOperands
			.endif

			.if char == 13 || char == 10 || char == 0
				jmp form_instruction
			.else
				jmp clear_tmp_str
			.endif

		deal_with_digit:
			.if nOperands == 2
				;ERROR
			.else
				.if nOperands == 0
					push edx
					lea edx, operands[0]
					invoke convert_digit_to_operand, esi, tmp_str_len, edx
					pop edx
				.else
					push edx
					lea edx, operands[sizeof Operand]
					invoke convert_digit_to_operand, esi, tmp_str_len, edx
					pop edx
				.endif
				inc nOperands
			.endif
			.if char == 13 || char == 10 || char == 0
				jmp form_instruction
			.else
				jmp clear_tmp_str
			.endif

		deal_with_local:
			.if nOperands == 2
				; ERROR
			.else
				push edx
				.if nOperands == 0
					lea edx, operands[0]
				.else
					lea edx, operands[sizeof Operand]
				.endif
				mov (Operand ptr[edx]).op_type, local_type
				mov (Operand ptr[edx]).op_size, 32
				mov edx, (Operand ptr[edx]).address
				invoke parse_local_operand, esi, edx
				pop edx
				inc nOperands
			.endif
			.if eax != 0
				; ERROR
			.endif
			.if char == 13 || char == 10 || char == 0
				jmp form_instruction
			.else
				jmp clear_tmp_str
			.endif

		form_instruction:
			lea ebx, operands[0]
			lea edx, operands[sizeof Operand]
			lea edi, encoded_machine_code

			push esi
			lea esi, instruct_str

			.if nOperands == 0
				invoke translate_asm_to_machine_code, esi, 0, 0, edi
			.elseif nOperands == 1
				invoke translate_asm_to_machine_code, esi, ebx, 0, edi
			.elseif nOperands == 2
				invoke translate_asm_to_machine_code, esi, ebx, edx, edi
			.endif

			pop esi

			push eax
			mov edx, offset now_address
			invoke WriteString

			mov al, '0'
			invoke WriteChar
			mov al, 'x'
			invoke WriteChar
			mov eax, initial_address
			mov ebx, 4
			invoke WriteHexB
			
			mov al, ':'
			invoke WriteChar
			mov al, ' '
			invoke WriteChar

			mov edx, edi
			invoke WriteString
			mov al, 13
			invoke WriteChar
			mov al, 10
			invoke WriteChar
			
			pop eax

			add initial_address, eax
			lea edx, instruct_str
			invoke Str_clear, edx, 256
			lea edx, encoded_machine_code
			invoke Str_clear, edx, 256

			mov nOperands, 0
			.if char == 0
				jmp break_loop
			.else
				jmp clear_tmp_str
			.endif
		
		final:
		pop esi
		inc ecx
		inc esi
		.continue

		break_loop:
		pop esi
		mov edx, pCharProcessed
		mov eax, char_processed
		mov DWORD PTR[edx], eax
		mov edx, pFinalAddress
		mov eax, initial_address
		mov DWORD PTR[edx], eax
		.break
	.endw
	ret
	
tokenize_instruction ENDP

tokenize_code_segment PROC USES eax ebx ecx edx esi,
	pCode: PTR BYTE,
	max_length: DWORD
	LOCAL first_symbol_name[256]: BYTE, second_symbol_name[256]: BYTE,
	      status: DWORD, char: BYTE, ptr1: PTR BYTE, ptr2: PTR  BYTE,
		  address: BYTE, nProcessed: DWORD

	mov address, 0
	mov status, BEGIN_STATE
	lea esi, first_symbol_name
	invoke Str_clear, esi, 256
	mov ptr1, esi
	lea esi, second_symbol_name
	invoke Str_clear, esi, 256
	mov ptr2, esi

	mov ecx, 0
	mov esi, pCode
	.while ecx <= max_length
		mov al, BYTE PTR[esi]
		mov char, al

		.if status == BEGIN_STATE
			.if (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z')
				mov status, FIRST_SYMBOL_STATE
				mov edx, ptr1
				mov al, char
				mov BYTE PTR[edx], al
				inc ptr1
			.endif
		.elseif status == FIRST_SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			    || (char >= '0' && char <= '9')
				mov edx, ptr1
				mov al, char
				mov BYTE PTR[edx], al
				inc ptr1
			.elseif char == ' '
				mov status, AFTER_FIRST_SYMBOL_STATE
			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp clear_str
			.endif
		.elseif status == AFTER_FIRST_SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z')
				mov status, SECOND_SYMBOL_STATE
				mov edx, ptr2
				mov al, char
				mov BYTE PTR[edx], al
				inc ptr2
			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp clear_str
			.endif
		.elseif status == SECOND_SYMBOL_STATE
			.if (char >= 'a' && char <= 'z')  || (char >= 'A' && char <= 'Z') \
			    || (char >= '0' && char <= '9')
				mov edx, ptr2
				mov al, char
				mov BYTE PTR[edx], al
				inc ptr2
			.elseif char == ' '
				mov status, AFTER_SECOND_SYMBOL_STATE
			.elseif char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp check_second_str
			.endif
		.elseif status == AFTER_SECOND_SYMBOL_STATE
			.if char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp check_second_str
			.elseif char == ' '
				; nothing
			.else
				mov status, USELESS_STATE
			.endif
		.elseif status == USELESS_STATE
			.if char == 13 || char == 10 || char == 0
				mov status, BEGIN_STATE
				jmp clear_str
			.endif
		.endif

		inc ecx
		inc esi
		.continue

		check_second_str:
			lea edx, second_symbol_name
			invoke Str_compare, offset start_proc_str, edx
			jne clear_str
			lea edx, first_symbol_name
			invoke push_list, offset proc_symbol_list, edx, address, 0
			inc esi
			lea ebx, nProcessed
			lea edx, address
			invoke tokenize_instruction, esi, max_length, address, ebx, edx
			add ecx, nProcessed
			add esi, nProcessed
			jmp clear_str

		clear_str:
			lea edx, first_symbol_name
			invoke Str_clear, edx, 256
			mov ptr1, edx
			lea edx, second_symbol_name
			invoke Str_clear, edx, 256
			mov ptr2, edx

			.if char == 0
				jmp end_loop
			.else
				jmp final
			.endif
			

		end_loop:
			.break

		final:
			inc ecx
			inc esi
	.endw

	ret

tokenize_code_segment ENDP

;--------------------------------------------------
convert_type_to_size PROC USES ebx ecx edx esi,
	str_addr: PTR BYTE
; Return: al = size
;--------------------------------------------------
	INVOKE Str_ucase, str_addr
	INVOKE Str_compare, str_addr, ADDR byte_name
	je byte_type
	INVOKE Str_compare, str_addr, ADDR word_name
	je word_type
	INVOKE Str_compare, str_addr, ADDR dword_name
	je dword_type
	mov al, 0
	ret
byte_type:
	mov al, 1
	ret
word_type:
	mov al, 2
	ret
dword_type:
	mov al, 4
	ret
convert_type_to_size ENDP

;--------------------------------------------------
judge_code_segment PROC USES ebx ecx edi,
	str_addr: PTR BYTE
; Return : al = 1 is code, else is not
;--------------------------------------------------
	mov edi, str_addr
	mov bh, [edi + 1]
	mov bl, [edi + 2]
	mov ch, [edi + 3]
	mov cl, [edi + 4]
	
	.IF (bh == 'c') && (bl == 'o') && (ch == 'd') && (cl == 'e')
		mov al, 1
	.ELSE
		mov al, 0
	.ENDIF

	ret
judge_code_segment ENDP

;--------------------------------------------------
tokenize_data_segment PROC USES ebx ecx edx esi edi,
	str_addr: PTR BYTE, ; the address of string
	max_length: DWORD	; max read length
;
; 里面是一些"var DWORD ...."的字符串
; 每读取到一个符号，就把这个符号的名称、大小、起始地址加到全局变量data_symbol_list中
; Tokenize data segment
; Return: eax = reading length (until code segment/max_length)
;--------------------------------------------------
	local data_address: DWORD, part_count: BYTE, number_count: DWORD,
		  flag_line_start: BYTE, pos_name: DWORD, pos_type: DWORD,
		  type_size: BYTE, flag_quote: BYTE, size_count: DWORD,
		  flag_dot: BYTE
	
	mov data_address, 0
	mov part_count, 0
	mov number_count, 0
	mov flag_line_start, 0
	mov pos_name, 0
	mov pos_type, 0
	mov type_size, 0
	mov flag_quote, 0
	mov size_count, 0
	mov flag_dot, 0

	mov ecx, max_length
	mov esi, str_addr
L1:
	mov bl, [esi]
	inc number_count
	.IF bl == 32 ; space
		.IF flag_line_start
			inc part_count
		.ENDIF
	.ELSEIF bl == 46 ; dot
		.IF flag_quote == 0
			INVOKE judge_code_segment, esi
			.IF al == 1
				add number_count, 4
				jmp end_tokenize
			.ENDIF
		.ENDIF
	.ELSEIF bl == 10 || bl == 13; \r\n
		.IF flag_line_start
			; set 0
			mov flag_line_start, 0
			mov pos_name, 0
			mov pos_type, 0
			mov part_count, 0
			; push_list
			mov dl, type_size
			shl dl, 3
			INVOKE push_list, 
				ADDR data_symbol_list, 
				ADDR var_name, 
				data_address,
				dl
			; calculate data_address
			.IF size_count == 0
				inc size_count
			.ENDIF
			mov edx, size_count
			mul type_size
			add data_address, edx
			; set 0
			mov size_count, 0
			mov type_size, 0
		.ENDIF
	.ELSE
		.IF flag_line_start == 0
			mov flag_line_start, 1
		.ENDIF

		.IF part_count <= 1
			.IF part_count == 0
				mov edi, OFFSET var_name
				add edi, pos_name
				inc pos_name
			.ELSE
				mov edi, OFFSET var_type
				add edi, pos_type
				inc pos_type
			.ENDIF
			mov [edi], bl
		.ELSE
			.IF type_size == 0
				; append \0
				mov edi, OFFSET var_name
				add edi, pos_name
				mov dl, 0
				mov [edi], dl
				mov edi, OFFSET var_type
				add edi, pos_type
				mov [edi], dl
				; calculate size
				INVOKE convert_type_to_size, ADDR var_type
				mov type_size, al
			.ENDIF
			; count the size
			; for byte string
			.IF type_size == 1
				.IF bl == 34 ; quote
					.IF flag_quote == 0
						mov flag_quote, 1
					.ELSE
						mov flag_quote, 0
					.ENDIF
				.ELSEIF flag_quote
					inc size_count
				.ELSEIF bl == 44 ; comma
					.IF size_count == 0
						inc size_count
					.ENDIF
					inc size_count
				.ELSE
					jmp next_L1
				.ENDIF
			; else
			.ELSE
				.IF bl == 44 ; comma
					.IF size_count == 0
						inc size_count
					.ENDIF
					inc size_count
				.ENDIF
			.ENDIF	
		.ENDIF
	.ENDIF
next_L1:
	inc esi
	dec ecx
	cmp ecx,0
	jne L1

end_tokenize:
	mov eax, number_count
	ret
tokenize_data_segment ENDP

END
