.386
.MODEL flat, stdcall

include operand.inc
include functions.inc
include parser_varible.inc
include tokenizer.inc
include Irvine32.inc
includelib Irvine32.lib

.data
;test11 DWORD ?
;test_local_operand LocalOperand < 0,0,0,0 >
;test_operand Operand <0,0, offset test_local_operand>
;test_code byte "A PROC ", 13, 10, "ADD abc 8", 13, 10, "MOV EAX EBX", 13, 10, "A ENDP", 13, 10, "B PROC", 13, 10, "JMP A", 13, 10, "B ENDP", 0
;test_code1 byte "A PROC", 13, 10, "MOV [EBP] 16", 13, 10, "MOV [EDX + 4*EAX+4] 10 ", 0
;test_code2 byte "RET", 0
;initial_address DWORD 0
;char_processed DWORD 0
;final_address DWORD 0
;
;test_symbol1 BYTE "abc", 0
;test_symbol2 BYTE "def", 0
;
;test_str BYTE "qddrs", 0

cmd_tail BYTE 129 DUP(0)

.code
main proc
	mov edx, OFFSET cmd_tail
	call GetCommandTail
	mov ecx, 129
loop_cmd_tail:
	mov bl, [edx]
	.IF bl == 0
		ret
	.ENDIF
	.IF bl != 32
		jmp start_cmd_tail
	.ENDIF
	inc edx
	loop loop_cmd_tail
	ret
start_cmd_tail:
	INVOKE process_file, edx
	INVOKE ExitProcess,0
	;invoke push_list, offset data_symbol_list, offset test_symbol1, 40, 0
	;invoke push_list, offset data_symbol_list, offset test_symbol2, 50, 0
	;
	;invoke Str_length, offset test_code1
	;invoke tokenize_instruction, offset test_code1, eax, \ 
			;initial_address, offset char_processed, offset final_address

main endp
end main
