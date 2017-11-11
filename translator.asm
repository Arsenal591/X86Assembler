.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
include operand.inc
include instruction_table.inc
includelib Irvine32.lib

.code
;--------------------------------------------------
translate_asm_to_machine_code PROC,
	mne_addr: PTR BYTE,			; the start address of a string, which is mnemonic
	op1_addr: PTR Operand,		; the first operand, null_ptr if no operand
	op2_addr: PTR Operand		; the second operand, null_ptr if no operand
;
; Generate machine code from asm languange
; Return: eax = bytes of the machine code
;--------------------------------------------------
	ret
translate_asm_to_machine_code ENDP

end
	