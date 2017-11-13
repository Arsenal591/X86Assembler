.386
.MODEL flat, stdcall

ExitProcess PROTO, dwExitCode: DWORD

find_opcode PROTO, 
	mne_addr: PTR BYTE, 
	op1_addr: PTR Operand, 
	op2_addr: PTR Operand,
	encoded_addr: PTR BYTE,
	digit_addr: PTR BYTE

get_encoding_of_register PROTO,
	reg: BYTE

get_encoding_of_operand PROTO,
	operand_addr: DWORD

get_modeRM PROTO,
	target_addr: DWORD,
	source_addr: DWORD,
	digit: BYTE

translate_asm_to_machine_code PROTO,
	mne_addr: PTR BYTE,	
	op1_addr: PTR Operand,
	op2_addr: PTR Operand,
	result_addr: PTR BYTE

parse_local_operand PROTO,
	str_addr: PTR BYTE,
	local_op: PTR LocalOperand