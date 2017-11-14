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

	; tokenize data segment
	INVOKE tokenize_data_segment, esi, bytesRead
	add esi, eax
	; tokenize code segment
	INVOKE tokenize_code_segment, esi, bytesRead
	ret
process_file ENDP
end