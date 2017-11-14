.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
include parser_varible.inc
include operand.inc
includelib Irvine32.lib

.data
var_name BYTE 256 DUP(0)
var_type BYTE 16 DUP(0)

byte_name BYTE "BYTE", 0
word_name BYTE "WORD", 0
dword_name BYTE "DWORD", 0
code_seg BYTE ".code", 0

.code 
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
	mov dh, [edi + 4]
	
	.IF (bh == 99) && (bl == 111) && (ch == 100) && (cl == 101)
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
	.ELSEIF bl == 10 ; \n
		.IF flag_line_start
			; set 0
			mov flag_line_start, 0
			mov pos_name, 0
			mov pos_type, 0
			mov part_count, 0
			mov type_size, 0
			; push_list
			INVOKE push_list, 
				ADDR data_symbol_list, 
				ADDR var_name, 
				data_address,
				type_size
			; calculate data_address
			mov eax, size_count
			mul type_size
			add data_address, eax
			mov size_count, 0
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
end