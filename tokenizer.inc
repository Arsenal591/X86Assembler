BEGIN_STATE = 0
FIRST_SYMBOL_STATE = 1
AFTER_FIRST_SYMBOL_STATE = 2
AFTER_CODE_LABEL_STATE = 7
AFTER_OPERAND_STATE = 3
DIGIT_STATE = 4
LOCAL_STATE = 5
SYMBOL_STATE = 6

SECOND_SYMBOL_STATE = 8
AFTER_SECOND_SYMBOL_STATE = 9
USELESS_STATE = 10

RegStringMappingElem STRUCT
	str1 BYTE 4 DUP(0)
	reg_num BYTE ?
RegStringMappingElem ENDS
