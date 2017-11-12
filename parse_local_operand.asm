.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
include operand.inc
includelib Irvine32.lib

.data
part0 BYTE 20 DUP(0)
part1 BYTE 20 DUP(0)
part2 BYTE 20 DUP(0)

.code
;--------------------------------------------------
append_byte_to_string PROC USES ebx esi,
	value: BYTE,
	pos: DWORD,
	count: BYTE
;--------------------------------------------------
	.IF count == 0
		mov esi, OFFSET part0
	.ELSEIF count == 1
		mov esi, OFFSET part1
	.ELSEIF count == 2
		mov esi, OFFSET part2
	.ELSE
		ret
	.ENDIF
	add esi, pos
	mov bl, value
	mov [esi], bl
	ret
append_byte_to_string ENDP

;--------------------------------------------------
judge_string_type PROC USES eax ebx ecx edx esi,
	count: BYTE,
	str_len: DWORD,
	flag: PTR BYTE
; flag: 1 is base, 2 is bias, 3 is index*scale
;--------------------------------------------------
	LOCAL local_flag: BYTE

	mov local_flag, 0

	.IF count == 0
		mov esi, OFFSET part0
	.ELSEIF count == 1
		mov esi, OFFSET part1
	.ELSEIF count == 2
		mov esi, OFFSET part2
	.ELSE
		ret
	.ENDIF
	mov ecx, str_len
loop_judge:
	mov bl, [esi]
	.IF (bl >= 48) && (bl <= 57)
		or local_flag, 2
	.ELSEIF (bl >= 65) && (bl <= 90)
		or local_flag, 1
	.ELSE
		inc esi
		loop loop_judge
	.ENDIF
	inc esi
	loop loop_judge

	mov esi, flag
	mov bl, local_flag
	mov [esi], bl
	ret
judge_string_type ENDP

;--------------------------------------------------
find_reg_type PROC USES ebx ecx edx esi,
	str_addr: PTR BYTE

; Return: al = reg type
;--------------------------------------------------
	mov esi, str_addr
	mov bl, [esi]
	inc esi
	mov cl, [esi]
	inc esi
	mov dl, [esi]
	
	.IF bl == 69
		.IF (cl == 65) && (dl == 88)
			mov al, EAX_num
		.ELSEIF (cl == 66) && (dl == 88)
			mov al, EBX_num
		.ELSEIF (cl == 67) && (dl == 88)
			mov al, ECX_num
		.ELSEIF (cl == 68) && (dl == 88)
			mov al, EDX_num
		.ELSEIF (cl == 66) && (dl == 80)
			mov al, EBP_num
		.ELSEIF (cl == 83) && (dl == 83)
			mov al, ESP_num
		.ELSEIF (cl == 68) && (dl == 73)
			mov al, EDI_num
		.ELSEIF (cl == 83) && (dl == 73)
			mov al, ESI_num
		.ELSE
			mov al, 1000b
		.ENDIF
	.ELSE
		mov al, 1000b
	.ENDIF
	ret
find_reg_type ENDP

;--------------------------------------------------
parse_mul_string PROC USES eax ebx ecx edx esi,
	str_addr: PTR BYTE,
	str_len: DWORD,
	index: PTR BYTE,
	scale: PTR BYTE
;--------------------------------------------------
	LOCAL star_pos: DWORD, flag_number: BYTE

	mov star_pos, 0
	mov flag_number, 0
	mov esi, str_addr
	mov ecx, str_len

loop_mul:
	mov bl, [esi]
	.IF (star_pos == 0) && (bl >= 48) && (bl <= 57)
		mov flag_number, 1
	.ENDIF
	.IF bl == 42
		mov star_pos, esi
	.ENDIF
	inc esi
	loop loop_mul

	; flag_number is 1 when number is before '*'

	.IF flag_number
		mov edx, str_addr
		mov ecx, star_pos
		sub ecx, edx
		call ParseInteger32
	.ELSE
		mov edx, star_pos
		inc edx
		mov ecx, str_addr
		add ecx, str_len
		sub ecx, star_pos
		dec ecx
		call ParseInteger32
	.ENDIF

	mov esi, scale
	mov [esi], al

	.IF flag_number
		mov esi, star_pos
		inc esi
		INVOKE find_reg_type, esi
	.ELSE
		mov esi, str_addr
		mov bl, [esi]
		.IF bl == 43
			inc esi
		.ENDIF
		INVOKE find_reg_type, esi
	.ENDIF

	mov esi, index
	mov [esi], al

	ret
parse_mul_string ENDP

;--------------------------------------------------
parse_local_operand PROC USES eax ebx ecx edx esi,
	str_addr: PTR BYTE,
	local_op: PTR LocalOperand
;
; Parse string like "ebx+2*ecx+10" and change it into LocalOperand
; 注意这三个部分的顺序可能会变，字符串中间会有空格
; Return: nothing
;--------------------------------------------------
	LOCAL count: BYTE, pos0: DWORD, pos1: DWORD, pos2: DWORD,
		  base: BYTE, index: BYTE, scale: BYTE, bias: SDWORD,
		  flag0: BYTE, flag1: BYTE, flag2: BYTE,
		  flag_bias: BYTE, flag_base: BYTE, flag_mul: BYTE

	INVOKE Str_ucase, str_addr
	INVOKE Str_length, str_addr
	mov ecx, eax
	mov esi, str_addr
	mov count, 0
	mov pos0, 0
	mov pos1, 0
	mov pos2, 0
	mov flag0, 0
	mov flag1, 0
	mov flag2, 0
	mov index, 0
	mov scale, 0
	mov bias, 0
L1:
	mov bl, [esi]
	.IF ((bl >= 48) && (bl <= 57)) || ((bl >= 65) && (bl <= 90)) || (bl == 42) || (bl == 43) || (bl == 45)
		.IF ((bl == 43) || (bl == 45)) && (pos0 != 0)
			inc count 
		.ENDIF
		
		.IF count == 0
			INVOKE append_byte_to_string, bl, pos0, count
			inc pos0
		.ELSEIF count == 1
			INVOKE append_byte_to_string, bl, pos1, count
			inc pos1
		.ELSEIF count == 2
			INVOKE append_byte_to_string, bl, pos2, count
			inc pos2
		.ELSE
			ret
		.ENDIF
	.ELSEIF bl == 32
		jmp next_L1
	.ELSE
		ret
	.ENDIF
next_L1:
	inc esi
	dec ecx
	cmp ecx,0
	jne L1

	mov flag_base, 0
	mov flag_bias, 0
	mov flag_mul, 0

	; 1 is base, 2 is bias, 3 is mul
	INVOKE judge_string_type, 0, pos0, ADDR flag0
	.IF flag0 == 1
		mov flag_base, 1
		INVOKE find_reg_type, ADDR part0
		.IF al >= 8
			ret
		.ELSE
			mov base, al
		.ENDIF
	.ELSEIF flag0 == 2
		mov flag_bias, 1
		mov edx, OFFSET part0
		mov ecx, pos0
		call ParseInteger32
		mov bias, eax
	.ELSEIF flag0 == 3
		mov flag_mul, 1
		INVOKE parse_mul_string, ADDR part0, pos0, ADDR index, ADDR scale
	.ELSE
		ret
	.ENDIF
	
	.IF count >= 1
		INVOKE judge_string_type, 1, pos1, ADDR flag1
		.IF flag1 == 1
			.IF flag_base
				ret
			.ENDIF
			mov flag_base, 1
			mov esi, OFFSET part1
			inc esi
			INVOKE find_reg_type, esi
			.IF al >= 8
				ret
			.ELSE
				mov base, al
			.ENDIF
		.ELSEIF flag1 == 2
			.IF flag_bias
				ret
			.ENDIF
			mov flag_bias, 1
			mov edx, OFFSET part1
			mov ecx, pos1
			call ParseInteger32
			mov bias, eax
		.ELSEIF flag1 == 3
			.IF flag_mul
				ret
			.ENDIF
			mov flag_mul, 1
			INVOKE parse_mul_string, ADDR part1, pos1, ADDR index, ADDR scale
		.ELSE
			ret
		.ENDIF

		.IF count >= 2
			INVOKE judge_string_type, 2, pos2, ADDR flag2
			.IF flag2 == 1
				.IF flag_base
					ret
				.ENDIF
				mov flag_base, 2
				mov esi, OFFSET part2
				inc esi
				INVOKE find_reg_type, esi
				.IF al >= 8
					ret
				.ELSE
					mov base, al
				.ENDIF
			.ELSEIF flag2 == 2
				.IF flag_bias
					ret
				.ENDIF
				mov flag_bias, 1
				mov edx, OFFSET part2
				mov ecx, pos2
				call ParseInteger32
				mov bias, eax
			.ELSEIF flag2 == 3
				.IF flag_mul
					ret
				.ENDIF
				mov flag_mul, 1
				INVOKE parse_mul_string, ADDR part2, pos2, ADDR index, ADDR scale
			.ELSE
				ret
			.ENDIF
		.ENDIF
	.ENDIF

	.IF flag_base == 0
		ret
	.ENDIF

	mov esi, local_op
	mov al, base
	mov [esi], al
	mov al, index
	mov [esi + 1], al
	mov al, scale
	mov [esi + 2], al
	mov eax, bias
	mov [esi + 4], eax

	ret
parse_local_operand ENDP

end