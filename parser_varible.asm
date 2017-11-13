.386
.MODEL flat, stdcall

include parser_varible.inc
include Irvine32.inc

Str_copy proto,
	source: ptr byte,
	target: ptr byte

Str_length proto,
	pString: ptr byte

Str_compare proto,
	string1: ptr byte,
	string2: ptr byte

.data
proc_symbols SymbolElem 256 DUP(<256 DUP(0), 0, 0 >)
proc_symbol_list SymbolList <0, offset proc_symbols>

code_symbols SymbolElem 256 DUP(<256 DUP(0), 0, 0 >)
code_symbol_list SymbolList <0, offset code_symbols>

data_symbols SymbolElem 256 DUP(<256 DUP(0), 0, 0 >)
data_symbol_list SymbolList <0, offset data_symbols>

.code
push_list proc USES ebx ecx edx esi edi,
	list: dword,
	symbol: dword,
	address: dword,
	op_size: byte
	LOCAL len: dword

	mov edx, list

	mov eax, (SymbolList ptr[edx]).len
	mov len, eax

	.if len > 255
		mov eax, -1
		ret
	.endif

	inc (SymbolList ptr[edx]).len
	mov ebx, (SymbolList ptr[edx]).address

	mov eax, sizeof SymbolElem
	mul len
	add ebx, eax; ebx now points to last elem of list

	; copy symbol string
	lea edi, (SymbolElem ptr[ebx]).symbol
	invoke Str_copy, symbol, edi

	; copy address value
	mov eax, address
	mov (SymbolElem ptr[ebx]).address, eax

	; copy size
	mov al, op_size
	mov (SymbolElem ptr[ebx]).op_size, al

	mov eax, 0
	ret
push_list endp

; return SymbolElem address(>0) when found, 0 otherwise
; return value is stored in EBX
find_symbol proc USES eax ecx edx esi,
	list: DWORD,
	symbol: DWORD
	LOCAL len: dword

	mov edx, list

	mov eax, (SymbolList ptr[edx]).len
	mov len, eax

	mov ecx, 0
	mov ebx, (SymbolList ptr[edx]).address
	.while ecx < len
		lea esi, (SymbolElem ptr[ebx]).symbol
		invoke Str_compare, esi, symbol

		je L1
		inc ecx
		add ebx, sizeof SymbolElem
		.continue

		L1:
		ret
	.endw

	mov ebx, 0
	ret
find_symbol endp

end
