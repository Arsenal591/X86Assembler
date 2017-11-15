SymbolElem STRUCT
	symbol BYTE 256 DUP(0)
	op_size BYTE ?
	address DWORD ?
SymbolElem ENDS

SymbolList STRUCT
	len DWORD ?
	address DWORD ?
SymbolList ENDS

externdef proc_symbol_list : SymbolList
externdef code_symbol_list : SymbolList
externdef data_symbol_list : SymbolList
