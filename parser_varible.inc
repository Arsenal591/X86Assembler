SymbolElem STRUCT
	symbol BYTE 256 DUP(0)
	op_size DWORD ?
	address DWORD ?
SymbolElem ENDS

SymbolList STRUCT
	len DWORD ?
	address DWORD ?
SymbolList ENDS

extern proc_symbol_list : SymbolList
extern code_symbol_list : SymbolList
extern data_symbol_list : SymbolList

push_list proto,
	list: dword,
	symbol: dword,
	address: dword

find_symbol proto,
	list: DWORD,
	symbol: DWORD
