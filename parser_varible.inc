SymbolElem STRUCT
	symbol BYTE 256 DUP(0)
	op_size DWORD ?
	address DWORD ?
SymbolElem ENDS

SymbolList STRUCT
	len DWORD ?
	address DWORD ?
SymbolList ENDS

externdef proc_symbol_list : SymbolList
externdef code_symbol_list : SymbolList
externdef data_symbol_list : SymbolList

push_list proto,
	list: dword,
	symbol: dword,
	address: dword,
	op_size: dword

find_symbol proto,
	list: DWORD,
	symbol: DWORD
