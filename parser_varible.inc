SymbolElem STRUCT
	symbol BYTE 256 DUP(0)
	address DWORD ?
SymbolElem ENDS

SymbolList STRUCT
	len DWORD ?
	address DWORD ?
SymbolList ENDS
