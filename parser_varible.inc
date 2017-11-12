SymbolElem STRUCT
	symbol BYTE 256 DUP(0)
	op_size DWORD ?
	address DWORD ?
SymbolElem ENDS

SymbolList STRUCT
	len DWORD ?
	address DWORD ?
SymbolList ENDS
