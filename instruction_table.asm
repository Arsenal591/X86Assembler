.386
.MODEL flat, stdcall

include instruction_table.inc

public table_mapping

.data
; -------- tables begin here --------
; (the following code is just an example)

AND_table_elems TableElem \
	<0,0>,\
	<7,1>,\
	<5,2>
AND_table Table <3, OFFSET AND_Table_elems>

; ----------- Above this line is WJL's work(tables A - M)
; below this line is JYH's work(tables N - Z) -----------


;------ that's the end of all instruction tables ------

;------ table mapping begins here --------

table_mapping_elems TableMappingElem \
	<"AND", offset AND_table>

table_mapping TableMapping <1, offset table_mapping_elems>
end