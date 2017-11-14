.386
.MODEL flat, stdcall

include operand.inc
include functions.inc
include parser_varible.inc
include tokenizer.inc
include Irvine32.inc
includelib Irvine32.lib

Str_length PROTO,
	pString: PTR BYTE

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

.data
test_local_operand LocalOperand < 0,0,0,0 >
test_operand Operand <0,0, offset test_local_operand>
test_code byte "MOV EAX EBX", 13, 10, "ADD abc 8", 0
initial_address DWORD 0
char_processed DWORD 0
final_address DWORD 0

test_symbol1 BYTE "abc", 0
test_symbol2 BYTE "def", 0
test_symbol3 BYTE "hij", 0
test_symbol4 BYTE "klm", 0
test_symbol5 BYTE "nop", 0
test_symbol6 BYTE "qrs", 0

test_str BYTE "qddrs", 0

.code
main proc
	invoke push_list, offset data_symbol_list, offset test_symbol1, 40, 0
	invoke push_list, offset data_symbol_list, offset test_symbol2, 50, 0

	invoke Str_length, offset test_code
	invoke tokenize_instruction, offset test_code, eax,\
	       initial_address, offset char_processed, \
		   offset final_address
	
	mov ecx, 0
	mov ebx, code_symbol_list.address
	.while ecx < code_symbol_list.len
		lea edx, (SymbolElem ptr[ebx]).symbol
		call WriteString

		inc ecx
		add ebx, sizeof SymbolElem
	.endw
	
	COMMENT !
	invoke push_list, offset proc_symbol_list, offset test_symbol1, 0, 100
	invoke push_list, offset proc_symbol_list, offset test_symbol2, 10, 0

	invoke push_list, offset data_symbol_list, offset test_symbol3, 20, 8
	invoke push_list, offset data_symbol_list, offset test_symbol4, 30, 16

	invoke push_list, offset code_symbol_list, offset test_symbol5, 40, 0
	invoke push_list, offset code_symbol_list, offset test_symbol6, 50, 0

	invoke convert_symbol_to_operand, offset test_str, offset test_operand, 22
	call WriteInt
	movzx eax, test_operand.op_type
	call WriteInt
	movzx eax, test_operand.op_size
	call WriteInt
	mov edx, test_operand.address
	mov eax, (OffsetOperand ptr[edx]).bias
	CALL WriteInt
	!
	ret
main endp
end main
