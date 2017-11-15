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

get_SIB PROTO,
	pOperand: DWORD

translate_asm_to_machine_code PROTO,
	mne_addr: PTR BYTE,	
	op1_addr: PTR Operand,
	op2_addr: PTR Operand,
	result_addr: PTR BYTE

parse_local_operand PROTO,
	str_addr: PTR BYTE,
	local_op: PTR LocalOperand

tokenize_data_segment PROTO,
	str_addr: PTR BYTE,
	max_length: DWORD

tokenize_code_segment PROTO,
	pCode: PTR BYTE,
	max_length: DWORD

process_file PROTO,
	file_path: PTR BYTE

process_code_label PROTO,
	pString: DWORD,
	pOperand: DWORD,
	current_address: DWORD

process_data_label PROTO,
	pString: DWORD,
	pOperand: DWORD,

process_proc_label PROTO,
	pString: DWORD,
	pOperand: DWORD,
	current_address: DWORD

tokenize_instruction PROTO,
	code: DWORD,
	max_length: DWORD,
	initial_address: DWORD,
	pCharProcessed: DWORD,
	pFinalAddress: DWORD

convert_symbol_to_operand PROTO,
	pString: DWORD,
	pOperand: DWORD,
	current_address: DWORD

tokenize_code_segment PROTO,
	pCode: PTR BYTE,
	max_length: DWORD

push_list PROTO,
	list: DWORD,
	symbol: DWORD,
	address: DWORD,
	op_size: BYTE

find_symbol PROTO,
	list: DWORD,
	symbol: DWORD
