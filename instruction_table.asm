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

; NEG instruction
NEG_table_elems TableElem \
	<F6h, reg_or_mem_type, 08h, null_type, 00h, 0, 0 >, \
	<F7h, reg_or_mem_type, 10h, null_type, 00h, 0, 0 >, \
	<F7h, reg_or_mem_type, 20h, null_type, 00h, 0, 0 >

NEG_table Table <LENGTHOF NEG_table_elems, OFFSET NEG_table_elems>

; OR instruction
OR_table_elems TableElem \
	<80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 0 >, \
	<81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 0 >, \
	<83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >, \
	<08h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >, \
	<09h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >, \
	<09h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >, \
	<0Ah, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >, \
	<0Bh, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >, \
	<0Bh, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

OR_table Table <LENGTHOF OR_table_elems, OFFSET OR_table_elems>

; POP instruction
POP_table_elems TableElem \
	<8Fh, reg_or_mem_type, 10h, null_type, 00h, 0, 0 >, \
	<8Fh, reg_or_mem_type, 20h, null_type, 00h, 0, 0 >, \
	<58h, reg_type, 10h, null_type, 00h, 1, 0 >, \
	<58h, reg_type, 20h, null_type, 00h, 1, 0 >

POP_table Table <LENGTHOF POP_table_elems, OFFSET POP_table_elems>

; PUSH instruction
PUSH_table_elems TableElem \
	<FFh, reg_or_mem_type, 10h, null_type, 00h, 0, 0 >, \
	<FFh, reg_or_mem_type, 20h, null_type, 00h, 0, 0 >, \
	<50h, reg_type, 10h, null_type, 00h, 1, 0 >, \
	<50h, reg_type, 20h, null_type, 00h, 1, 0 >, \
	<6Ah, imm_type, 08h, null_type, 00h, 0, 0 >, \
	<68h, imm_type, 10h, null_type, 00h, 0, 0 >, \
	<68h, imm_type, 20h, null_type, 00h, 0, 0 >

PUSH_table Table <LENGTHOF PUSH_table_elems, OFFSET PUSH_table_elems>

; RET instruction
RET_table_elems TableElem \
	<C3h, null_type, 00h, null_type, 00h, 0, 0 >, \
	<CBh, null_type, 00h, null_type, 00h, 0, 0 >, \
	<C2h, imm_type, 10h, null_type, 00h, 0, 0 >, \
	<CAh, imm_type, 10h, null_type, 00h, 0, 0 >

RET_table Table <LENGTHOF RET_table_elems, OFFSET RET_table_elems>

; SAL/SAR/SHL/SHR instruction
SAL_table_elems TableElem \
	<C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >

SAL_table Table <LENGTHOF SAL_table_elems, OFFSET SAL_table_elems>

SAR_table_elems TableElem \
	<C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >

SAR_table Table <LENGTHOF SAR_table_elems, OFFSET SAR_table_elems>

SHL_table_elems TableElem \
	<C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >

SHL_table Table <LENGTHOF SHL_table_elems, OFFSET SHL_table_elems>

SHR_table_elems TableElem \
	<C0h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<C1h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >

SHR_table Table <LENGTHOF SHR_table_elems, OFFSET SHR_table_elems>

; SUB instruction
SUB_table_elems TableElem \
	<80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 0 >, \
	<81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 0 >, \
	<83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >, \
	<28h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >, \
	<29h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >, \
	<29h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >, \
	<2Ah, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >, \
	<2Bh, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >, \
	<2Bh, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

SUB_table Table <LENGTHOF SUB_table_elems, OFFSET SUB_table_elems>

; XCHG instruction
XCHG_table_elems TableElem \
	<86h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >, \
	<86h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >, \
	<87h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >, \
	<87h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >, \
	<87h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >, \
	<87h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

XCHG_table Table <LENGTHOF XCHG_table_elems, OFFSET XCHG_table_elems>

; XOR instruction
XOR_table_elems TableElem \
	<80h, reg_or_mem_type, 08h, imm_type, 08h, 0, 0 >, \
	<81h, reg_or_mem_type, 10h, imm_type, 10h, 0, 0 >, \
	<81h, reg_or_mem_type, 20h, imm_type, 20h, 0, 0 >, \
	<83h, reg_or_mem_type, 10h, imm_type, 08h, 0, 0 >, \
	<83h, reg_or_mem_type, 20h, imm_type, 08h, 0, 0 >, \
	<30h, reg_or_mem_type, 08h, reg_type, 08h, 0, 0 >, \
	<31h, reg_or_mem_type, 10h, reg_type, 10h, 0, 0 >, \
	<31h, reg_or_mem_type, 20h, reg_type, 20h, 0, 0 >, \
	<32h, reg_type, 08h, reg_or_mem_type, 08h, 0, 0 >, \
	<33h, reg_type, 10h, reg_or_mem_type, 10h, 0, 0 >, \
	<33h, reg_type, 20h, reg_or_mem_type, 20h, 0, 0 >

XOR_table Table <LENGTHOF XOR_table_elems, OFFSET XOR_table_elems>

;------ that's the end of all instruction tables ------

;------ table mapping begins here --------

table_mapping_elems TableMappingElem \
	<"AND", offset AND_table>

table_mapping TableMapping <1, offset table_mapping_elems>
end
