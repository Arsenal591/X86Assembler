.386
.MODEL flat, stdcall

include operand.inc
include instruction_table.inc

public table_mapping

.data
; -------- tables begin here --------
; (the following code is just an example)

ADD_table_elems TableElem \
	<80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 0 >, \
	<81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 0 >, \
	<83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >, \
	<00h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >, \
	<01h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >, \
	<01h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >, \
	<02h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >, \
	<03h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >, \
	<03h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

ADD_table Table <LENGTHOF ADD_table_elems, OFFSET AND_Table_elems>

; ----------- Above this line is WJL's work(tables A - M)
; below this line is JYH's work(tables N - Z) -----------


;------ that's the end of all instruction tables ------

;------ table mapping begins here --------

table_mapping_elems TableMappingElem \
	<"AND", offset AND_table>

table_mapping TableMapping <1, offset table_mapping_elems>
end
