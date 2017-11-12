.386
.MODEL flat, stdcall

include operand.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib

.data
mme BYTE "JMP", 0
op1_reg OffsetOperand <01234h>
op1 Operand <offset_type, 20h, OFFSET op1_reg>
result BYTE 50 DUP(0)

.code
main proc
	INVOKE translate_asm_to_machine_code, ADDR mme, ADDR op1, 0, ADDR result
	INVOKE ExitProcess,0
main endp
end main
