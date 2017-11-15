.386
.MODEL flat, stdcall

include Irvine32.inc
include functions.inc
includelib Irvine32.lib

.data
BUFFER_SIZE = 5000
buffer BYTE BUFFER_SIZE DUP(0)
.code
;--------------------------------------------------
judge_data_segment PROC USES ebx ecx edi,
	str_addr: PTR BYTE
; Return : al = 1 is code, else is not
;--------------------------------------------------
	mov edi, str_addr
	mov bh, [edi + 1]
	mov bl, [edi + 2]
	mov ch, [edi + 3]
	mov dh, [edi + 4]
	
	.IF (bh == 100) && (bl == 97) && (ch == 116) && (cl == 97)
		mov al, 1
	.ELSE
		mov al, 0
	.ENDIF

	ret
judge_data_segment ENDP

;--------------------------------------------------
process_file PROC USES eax ecx edx esi,
	file_path: PTR BYTE ; the string of file path
;
; generate 
; Return: nothing
;--------------------------------------------------
	LOCAL bytesRead: DWORD

	mov bytesRead, 0
	mov edx, file_path
	call OpenInputFile
	.IF eax == INVALID_HANDLE_VALUE
		call WriteWindowsMsg
		ret
	.ENDIF
	mov edx, OFFSET buffer
	mov ecx, BUFFER_SIZE
	call ReadFromFile
	jnc success_read
	call WriteWindowsMsg
	ret
success_read:
	mov esi, OFFSET buffer
	; find .data and add esi
	mov ecx, bytesRead
loop_read:
	mov bl, [esi]
	.IF bl == 46 ; dot
		INVOKE judge_data_segment, esi
		.IF al == 1
			add esi, 5
			jmp find_data
		.ENDIF
	.ENDIF
	inc esi
	loop loop_read
	ret

find_data:
	; tokenize data segment
	INVOKE tokenize_data_segment, esi, bytesRead
	add esi, eax
	; tokenize code segment
	INVOKE tokenize_code_segment, esi, bytesRead
	ret
process_file ENDP
end