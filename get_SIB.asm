.386
.MODEL flat, stdcall

include operand.inc
include functions.inc

.code
; get SIB
; return value is stored in AL
get_SIB PROC USES edx,
	pOperand: DWORD
	LOCAL index_num: BYTE, base_num: BYTE, ss_num: BYTE, scale: BYTE

	mov edx, pOperand
	mov edx, (Operand ptr[edx]).address

	invoke get_encoding_of_register, (LocalOperand ptr[edx]).base
	mov base_num, al
	invoke get_encoding_of_register, (LocalOperand ptr[edx]).index
	mov index_num, al

	mov al, (LocalOperand ptr[edx]).scale
	mov scale, al
	.if scale == 0
		mov index_num, 100b
	.endif

	.if scale == 0 || scale == 1
		mov ss_num, 00b
	.elseif scale == 2
		mov ss_num, 01b
	.elseif scale == 4
		mov ss_num, 10b
	.elseif scale == 8
		mov ss_num, 11b
	.endif

	mov al, base_num
	shl index_num, 3
	add al, index_num
	shl ss_num, 6
	add al, ss_num

	ret
get_SIB ENDP

end
