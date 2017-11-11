Operand STRUCT
	op_type BYTE ?
	op_size BYTE ?
	align DWORD 
	address DWORD ?
Operand ENDS

ImmOperand struct
	value dword ?
ImmOperand ends

RegOperand struct
	reg byte ?
RegOperand ends

GlobalOperand struct
	value dword ?
GlobalOperand ends

LocalOperand struct
	base byte ?
	index byte ?
	scale byte ?
	align dword
	bias dword ?
LocalOperand ends

OffsetOperand struct
	bias dword ?
OffsetOperand ends

; register symbols
EAX_num = 0000b
ECX_num = 0001b
EDX_num = 0010b
EBX_num = 0011b
ESP_num = 0100b
EBP_num = 0101b
ESI_num = 0110b
EDI_num = 0111b
all_regs = 1111b

full_reg = 0000b
half_reg = 0001b
low_quar_reg = 0010b
high_quar_reg = 0011b

;operand types
null_type = 00000000b
reg_type = 00000001b
imm_type = 00000010b
global_type = 00000100b
local_type = 00001000b
offset_type = 00010000b

mem_type = 00001100b
reg_or_mem_type = 00001101b

end