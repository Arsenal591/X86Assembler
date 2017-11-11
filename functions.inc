.386
.MODEL flat, stdcall

.code
find_opcode PROTO, 
	mne_addr: PTR BYTE, 
	op1_addr: PTR Operand, 
	op2_addr: PTR Operand,
	encoded_addr: PTR BYTE,
	digit_addr: PTR BYTE
