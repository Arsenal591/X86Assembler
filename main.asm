.386
.MODEL flat, stdcall

include operand.inc
include functions.inc
include Irvine32.inc
includelib Irvine32.lib

.data
mme BYTE "MOV", 0
op1_reg RegOperand <EDX_num>
op1 Operand <reg_type, 20h, OFFSET op1_reg>
op2_reg IMMOperand <01234h>
op2 Operand <imm_type, 20h, OFFSET op2_reg>
result BYTE 50 DUP(0)
test_string BYTE " 25 * ecx + ebx ", 0
local_result LocalOperand <>
.code
main proc
	; INVOKE translate_asm_to_machine_code, ADDR mme, ADDR op1, ADDR op2, ADDR result
	INVOKE parse_local_operand, ADDR test_string, ADDR local_result
	INVOKE ExitProcess,0
main endp
end main
