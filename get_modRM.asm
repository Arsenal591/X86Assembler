.386
.MODEL flat, stdcall

include operand.inc
include functions.inc

public get_modeRM

.code

get_encoding_of_register PROC,
	reg: BYTE
	LOCAL tmp: BYTE

	mov al, reg
	mov tmp, al
	shr tmp, 4

	mov al, reg
	and al, 00001111b

	.if tmp == high_quar_reg
		add al, 4
	.endif

	ret

get_encoding_of_register ENDP

get_encoding_of_operand PROC USES ebx edx,
	operand_addr: DWORD
	LOCAL op_type: BYTE

	mov edx, operand_addr
	mov ebx, (Operand ptr[edx]).address

	push eax
	mov al, (Operand ptr[edx]).op_type
	mov op_type, al
	pop eax

	.if op_type == reg_type
		invoke get_encoding_of_register, (RegOperand ptr[ebx]).reg
	.elseif op_type == global_type
		mov al, 101b
	.elseif op_type == local_type
		invoke get_encoding_of_register, (LocalOperand ptr[ebx]).base

	.endif

	ret

get_encoding_of_operand ENDP

; given two operands(sometimes 1) and a /digit value, get the modeR/M byte of it
; return value is stored in al
get_modeRM PROC USES ebx edx,
	target_addr: DWORD,
	source_addr: DWORD,
	digit: BYTE
	LOCAL mode: BYTE, RM: BYTE, reg: BYTE, col_addr: DWORD, row_addr: DWORD,\
		  type1: BYTE, type2: BYTE, bias: DWORD, base: BYTE

	mov ebx, target_addr
	mov edx, source_addr
	; find column operand and row operand
	.if edx == 0
		mov col_addr, ebx
		mov row_addr, 0
	.else
		push eax
		mov al, (Operand ptr[ebx]).op_type
		mov type1, al
		mov al, (Operand ptr[edx]).op_type
		mov type2, al
		pop eax

		.if type1 == global_type || type1 == local_type
			mov col_addr, ebx
			mov row_addr, edx
	
		.elseif type2 == global_type || type2 == local_type
			mov col_addr, edx
			mov row_addr, ebx

		.elseif type2 == imm_type
			mov row_addr, edx
			mov col_addr, ebx

		.else
			mov col_addr, edx
			mov row_addr, ebx
		.endif
	.endif

	mov ebx, col_addr
	mov edx, row_addr
	;get mod of col_addr
	push eax
	mov al, (Operand ptr[ebx]).op_type
	mov type1, al
	pop eax

	.if type1 == reg_type
		mov mode, 11b
	.elseif type1 == global_type
		mov mode, 00b
	.else
		push edx
		mov edx, (Operand ptr[ebx]).address

		push eax
		mov eax, (LocalOperand ptr[edx]).bias
		mov bias, eax
		pop eax

		.if bias >= 1024
			mov mode, 10b
		.elseif bias > 0
			mov mode, 01b
		.else
			push eax
			mov al, (LocalOperand ptr[edx]).base
			mov base, al
			pop eax
			.if base == EBP_num
				mov mode, 01b
			.else
				mov mode, 00b
			.endif
		.endif

		pop edx
	.endif

	;get RM of col_addr
	invoke get_encoding_of_operand, ebx
	mov RM, al

	;get reg of row_addr
	.if edx == 0
		mov al, digit
		mov reg, al
	.else
		push eax
		mov al, (Operand ptr[edx]).op_type
		mov type2, al
		pop eax

		.if type2 == imm_type
			mov al, digit
			mov reg, al
		.else
			invoke get_encoding_of_operand, edx
			mov reg, al
		.endif
	.endif

	;get the result
	shl mode, 6
	shl reg, 3
	mov al, RM
	add al, reg
	add al, mode

	ret
get_modeRM ENDP

end
