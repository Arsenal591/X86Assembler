.386
.MODEL flat, stdcall

include operand.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib

.data
;mne BYTE "MOV", 0
;op1 Operand <reg_type, 10h, 12345678h>
;op2 Operand <imm_type, 10h, 98765432h>
;encoded BYTE ?
;digit BYTE ?

.code
main proc
	
	;INVOKE find_opcode, 
		;ADDR mne, 
		;ADDR op1, 
		;ADDR op2, 
		;ADDR encoded, 
		;ADDR digit
	ret
main endp
end main
