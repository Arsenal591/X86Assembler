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